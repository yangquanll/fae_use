#include <binder/ProcessState.h>
#include <binder/IPCThreadState.h>
#include <binder/IServiceManager.h>
#include <binder/Parcel.h>

#include <TrustKernelIfaaService.h>
#include <log.h>

#ifdef LOG_TAG
#undef LOG_TAG
#endif

#define LOG_TAG "[TKIfaaServer]"

using namespace android;

int
main() {
	int rc;
    sp<ProcessState> proc(ProcessState::self());
    sp<IServiceManager> sm = defaultServiceManager();
    rc = defaultServiceManager()->addService(
            com::trustkernel::TrustKernelIfaaService::B_NAME,
			com::trustkernel::TrustKernelIfaaService::getInstance());

	ALOGE("IfaaService(%04x) Add Service with %d starts to work\n",
		com::trustkernel::TrustKernelIfaaService::kVersion, rc);

    ProcessState::self()->startThreadPool();
    IPCThreadState::self()->joinThreadPool();
	return 0;
}
