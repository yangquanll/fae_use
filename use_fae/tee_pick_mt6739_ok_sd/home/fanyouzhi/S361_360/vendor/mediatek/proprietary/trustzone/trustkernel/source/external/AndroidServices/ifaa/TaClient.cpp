#include <pthread.h>
#include <android/log.h>

#include <tee_client_api.h>

#include "TaClient.h"

#define LOG_TAG "TrustKernelIFAA_v2"

#define LOG_D(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG ,__VA_ARGS__)
#define LOG_I(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG ,__VA_ARGS__)
#define LOG_E(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG ,__VA_ARGS__)
#define LOG(...)   __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG ,__VA_ARGS__)

static TEEC_Context context;
static TEEC_Session session = { 0 };
static uint32_t is_init = 0;

static pthread_mutex_t ifaa_mtx = PTHREAD_MUTEX_INITIALIZER;

static const TEEC_UUID IFAA_V2_UUID = { 0x8b1e0e41, 0x2636, 0x11e1,
		{ 0xad, 0x9e, 0x00, 0x02, 0xa5, 0xd5, 0xc5, 0x1b } };

static TEEC_Result open_tee_session()
{
    TEEC_Result res;
	uint32_t orig;

    pthread_mutex_lock(&ifaa_mtx);

	if (is_init) {
        res = TEEC_SUCCESS;
        goto out;
	}

	if ((res = TEEC_InitializeContext(NULL, &context)) != TEEC_SUCCESS) {
		LOG_E("TEEC_InitializeContext failed with return value: 0x%08x\n", res);
        goto out;
	}

	res = TEEC_OpenSession(&context, &session, &IFAA_V2_UUID,
        TEEC_LOGIN_PUBLIC, NULL, NULL, &orig);

	if (res != TEEC_SUCCESS) {
		LOG_E("TEEC_OpenSession failed with return value: 0x%08x, orig 0x%08x\n",
            res, orig);
		goto err;
	}

	is_init = 1;
    goto out;

err:
	TEEC_FinalizeContext(&context);

out:
    pthread_mutex_unlock(&ifaa_mtx);
	return res;
}

static void close_tee_session()
{
    pthread_mutex_lock(&ifaa_mtx);

	if (!is_init) {
		LOG_I("Session and context not initialized\n");
        pthread_mutex_unlock(&ifaa_mtx);
        return;
	}

	TEEC_CloseSession(&session);
	TEEC_FinalizeContext(&context);
	is_init = 0;

    pthread_mutex_unlock(&ifaa_mtx);
}

int invoke_command(void *send_buf, uint32_t sbuf_len, void *rcv_buf, uint32_t *rbuf_len)
{
	TEEC_Result res;
    TEEC_Operation op;

	uint32_t orig;

    if ((res = open_tee_session())) {
        return res;
    }

    memset(&op, 0, sizeof(op));

	if (send_buf == NULL || rcv_buf == NULL || sbuf_len == 0) {
		LOG_E("%s: Bad parameters.", __func__);
		return TEEC_ERROR_BAD_PARAMETERS;
	}

	op.params[0].tmpref.buffer = send_buf;
	op.params[0].tmpref.size = sbuf_len;
	op.params[1].tmpref.buffer = rcv_buf;
	op.params[1].tmpref.size = *rbuf_len;
	op.paramTypes = TEEC_PARAM_TYPES(TEEC_MEMREF_TEMP_INPUT, TEEC_MEMREF_TEMP_OUTPUT, TEEC_NONE, TEEC_NONE);

	res = TEEC_InvokeCommand(&session, 0, &op, &orig);

	if (res != TEEC_SUCCESS) {
		LOG("%s: InvokeCommand() failed with 0x%08x, orig 0x%08x\n", __func__, res, orig);
		if (orig != TEEC_ORIGIN_TRUSTED_APP) {
            close_tee_session();
		}
		return res;
	}

	*rbuf_len = op.params[1].tmpref.size;

    return TEEC_SUCCESS;
}

#ifdef __cplusplus
extern "C" {
#endif

int alipay_tz_invoke_command(void *send_buf, uint32_t sbuf_len, void *rcv_buf, uint32_t *rbuf_len)
{
    return invoke_command(send_buf, sbuf_len, rcv_buf, rbuf_len);
}

#ifdef __cplusplus
}
#endif
