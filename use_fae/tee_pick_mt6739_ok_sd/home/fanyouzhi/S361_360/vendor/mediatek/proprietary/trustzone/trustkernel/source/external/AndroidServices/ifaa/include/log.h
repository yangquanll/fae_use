#ifndef COM_TRUSTKERNEL_LIB_TKSERVICE_DEBUG_
#define COM_TRUSTKERNEL_LIB_TKSERVICE_DEBUG_

#include <android/log.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif
    void hexDump(const void* data, size_t size, const char *desc);
    void rdm_fill_buffer (void * buf, size_t len);
#ifdef __cplusplus
}
#endif

#ifndef ALOGE
#define ALOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#endif

#ifndef ALOGW
#define ALOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__))
#endif

#ifndef ALOGD
#define ALOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#endif

#define LOGE           ALOGE
#define LOGW           ALOGW

#ifdef DEBUG
#define LOGD           ALOGD
#else
#define LOGD(...)      do { } while(0)
#endif

#endif 
