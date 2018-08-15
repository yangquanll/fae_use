package org.ifaa.android.manager;

import android.content.Context;

public abstract class IFAAManagerV2 extends IFAAManager {

    /*
     *   功能描述：实现REE到TAA的通道。┊
     *   参数描述：byte[] param 用于传输到IFAA TA的数据buffer。
     *   返回值：byte[] 返回IFAA TA返回REE的数据buffer。
     *
     **/ 

    public abstract byte[] processCmdV2(Context context, byte[] param);

}
