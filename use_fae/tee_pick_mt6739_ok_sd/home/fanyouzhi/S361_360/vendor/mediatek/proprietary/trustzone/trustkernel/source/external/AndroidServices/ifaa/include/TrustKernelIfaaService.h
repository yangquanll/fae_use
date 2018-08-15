#ifndef COM_TRUSTKERNEL_LIB_TKLIBSERVICE_
#define COM_TRUSTKERNEL_LIB_TKLIBSERVICE_

#include <com/trustkernel/BnTrustKernelIfaaService.h>

#define TKSERVER_API_VERSION(maj,mid) \
    ((((maj) & 0xff) << 8) | ((mid) & 0xff))

namespace com {
    namespace trustkernel {

        class TrustKernelIfaaService :
            public BnTrustKernelIfaaService, public ::android::IBinder::DeathRecipient
        {
            public:
                static TrustKernelIfaaService* getInstance() {
                    if (sInstance == NULL) {
                        sInstance = new TrustKernelIfaaService();
                    }
                    return sInstance;
                }

            virtual ::android::binder::Status invoke_command(const std::vector<uint8_t>& input,
                                                            std::vector<uint8_t>* output,
                                                            int32_t out_capacity,
                                                            int32_t *_aidl_retval);

                virtual void binderDied(const ::android::wp<IBinder>& who);

                static const uint16_t kVersion = TKSERVER_API_VERSION(3, 0);
                static const ::android::String16 B_NAME;

            private:
                static TrustKernelIfaaService* sInstance;
        };
    }
}

#endif
