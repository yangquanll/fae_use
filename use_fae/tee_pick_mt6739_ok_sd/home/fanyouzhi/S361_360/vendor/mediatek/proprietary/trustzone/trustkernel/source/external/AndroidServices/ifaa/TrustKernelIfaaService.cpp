#include <vector>

#include <log.h>
#include <TaClient.h>
#include <TrustKernelIfaaService.h>

#ifdef LOG_TAG
#undef LOG_TAG
#endif
#define LOG_TAG "[IfaaTKService]"

using android::binder::Status;
using android::String16;

using std::vector;

namespace com {
    namespace trustkernel {

            TrustKernelIfaaService* TrustKernelIfaaService::sInstance = NULL;
            const String16 TrustKernelIfaaService::B_NAME("IfaaTKService");

            Status TrustKernelIfaaService::invoke_command(const vector<uint8_t>& input,
                                                        vector<uint8_t>* output,
                                                        int32_t output_capacity,
                                                        int32_t *_aidl_retval) {
                int rc;
                uint32_t outbuf_size = output->size() - sizeof(uint32_t);
                uint8_t *outbuf;

				if (output->size() <= sizeof(uint32_t)) {
					*_aidl_retval = -E2BIG;
					return Status::fromExceptionCode(Status::EX_NONE);
				}

                outbuf = output->data();

                if (outbuf == NULL) {
                    *_aidl_retval = -ENOMEM;
                    return Status::fromExceptionCode(Status::EX_NONE);
                }

                rc = ::invoke_command(
                            const_cast<uint8_t *>(input.data()),
                            static_cast<uint32_t>(input.size()),
                            outbuf + sizeof(outbuf_size), &outbuf_size);

                if (rc == 0) {
                    ALOGD("OUTBUF len=%u", outbuf_size);

					/*  out buffer layout:
							|<-- size(4) -->|<-- buffer(size) -->|
					*/
					memcpy(outbuf, &outbuf_size, sizeof(outbuf_size));
                } else {
                    ALOGE("invoke command failed with %d", rc);
                }

                *_aidl_retval = rc;

                return Status::fromExceptionCode(Status::EX_NONE);
            }

            void TrustKernelIfaaService::binderDied(const ::android::wp<IBinder>& who) {
                ALOGD("binder died");
            }
    }
}
