package org.ifaa.android.manager;

import android.os.Build;
import android.os.IBinder;
import android.os.ServiceManager;
import android.os.ServiceManager.ServiceNotFoundException;

import android.content.Context;
import android.content.Intent;
import android.provider.Settings;
import android.util.Log;

import org.ifaa.android.manager.ta.TACommands;
import org.ifaa.android.manager.ta.TAInterationV1;
import org.ifaa.android.manager.ta.TAInterationV2;
import org.ifaa.android.manager.util.ByteUtils;
import org.ifaa.android.manager.util.Result;

import com.trustkernel.ITrustKernelIfaaService;

public class TrustKernelIFAAManager extends IFAAManagerV2 {

    public static String TAG = "TrustKernelIFAAManager";
    public static String IFAA_TK_SERVICE = "IfaaTKService";

    final int MSG_SIZE = 1024 * 8;

    private Context ctx = null;
    private int authType = 0;
    private ITrustKernelIfaaService service;

    private String devicemodel = null;
    private int biotypes = -1;

    public TrustKernelIFAAManager(Context ctx, int authType) throws ServiceNotFoundException {
        final IBinder binder;

        this.ctx = ctx;
        this.authType = authType;

        if (ctx.getApplicationInfo().targetSdkVersion >= Build.VERSION_CODES.O) {
            binder = ServiceManager.getServiceOrThrow(IFAA_TK_SERVICE);
        } else {
            binder = ServiceManager.getService(IFAA_TK_SERVICE);
        }

        service = ITrustKernelIfaaService.Stub.asInterface(binder);

        if (service == null) {
            Log.e(TAG, "Failed to acquire instance of TrustkernelIfaaService");
        }
    }

    @Override
    public String getDeviceModel() {
        if (devicemodel == null) {
            Result result = TAInterationV2.sendCommand(
                                                this,
                                                ctx,
                                                TACommands.IFAA_ANDROID_GET_DEVICE_MODEL);
            if (result.getStatus() == Result.RESULT_SUCCESS) {
                devicemodel = new String(result.getData());
            }
        }
        Log.d(TAG, "getDeviceModel: " + devicemodel);
        return devicemodel;
    }

    @Override
    public int getSupportBIOTypes(Context context) {
        if (biotypes == -1) {
            Log.d(TAG, "PressCmdV2:start");
            Result result = TAInterationV2.sendCommand(this,
                                            context,
                                            TACommands.IFAA_ANDROID_GET_SUPPORT_BIO_TYPE);
            Log.d(TAG, "getSupportBIOTypes: " + biotypes);
            if(result.getStatus() == Result.RESULT_SUCCESS) {
                biotypes = ByteUtils.toInt(result.getData());
            }
        }
        Log.d(TAG, "getSupportBIOTypes: " + biotypes);
        return biotypes;
    }


    @Override
    public int getVersion() {
        Log.d(TAG,"processCmdV2 Version 2\n");
        return 2;
    }

    @Override
    public int startBIOManager(Context context, int authType) {
        Log.d(TAG, "startBIOManager");
        Intent intent = new Intent(Settings.ACTION_SECURITY_SETTINGS);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        context.startActivity(intent);
        return 0;
    }

    @Override
    public byte[] processCmdV2(Context context, byte[] data) {
        int ret;

        byte[] recv = new byte[MSG_SIZE];
        int recv_len;

        try {
            ret = service.invoke_command(data, recv, recv.length);
            if (ret != 0) {
                Log.e(TAG, "Invoke Command failed with 0x%x\n" + ret);
                return null;
            }
        } catch(Exception e){
            Log.e(TAG,e.getMessage(), new Throwable());
            Log.e(TAG,"processCmdV2 ERROR");
        }

        recv_len = ByteUtils.toInt(recv);
        Log.d(TAG, "processCmdV2 payload length: " + recv_len);

        if (recv_len + 4 > recv.length) {
            Log.e(TAG, "processCmdV2: payload over size");
            return null;
        }

        byte[] ret_data = new byte[recv_len];

        ByteUtils.copy(recv, 4, recv_len, ret_data, 0);
        return ret_data;
    }
}
