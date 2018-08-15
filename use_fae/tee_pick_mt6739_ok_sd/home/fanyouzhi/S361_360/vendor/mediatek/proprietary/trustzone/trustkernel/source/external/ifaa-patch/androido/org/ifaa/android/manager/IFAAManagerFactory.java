package org.ifaa.android.manager;

import android.content.Context;

import android.os.ServiceManager;
import android.os.ServiceManager.ServiceNotFoundException;

public class IFAAManagerFactory {

    //private static IFAAManager instance = null;
    private static IFAAManagerV2 instance = null;

    public static IFAAManager getIFAAManager(Context ctx, int authType) throws ServiceNotFoundException {
        synchronized (IFAAManagerFactory.class) {
            if (instance == null) {
                instance = new TrustKernelIFAAManager(ctx, authType);
            }
            return instance;
        }
    }
}
