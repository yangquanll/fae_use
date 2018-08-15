/*
 * Copyright (c) 2015-2018 TrustKernel Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files
 * (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include <cutils/log.h>

#include <android/hardware/keymaster/3.0/IKeymasterDevice.h>
#include <hardware/keymaster_defs.h>

#include "key_store_service.h"
#include "keystore_utils.h"

using android::String8;
using android::hardware::keymaster::V3_0::KeyParameter;

using keystore::hidl_vec;

hidl_vec<KeyParameter> acquireSoterParams(::KeyStore *mKeyStore,
                                          const hidl_vec<KeyParameter>& params,
                                          uid_t uid) {
    ALOGE("acquireSoterParams() ++");

    hidl_vec<KeyParameter> newParams(params);
    for (size_t i = 0; i < newParams.size(); ++i) {
        KeyParameter &param = newParams[i];
        Blob keyBlob;

        if (static_cast<keymaster_tag_t>(param.tag) ==
            KM_TAG_SOTER_AUTO_SIGNED_COMMON_KEY_WHEN_GET_PUBLIC_KEY) {


            String8 keyName(reinterpret_cast<const char *>(param.blob.data()),
                param.blob.size());

            ResponseCode rc = mKeyStore->getKeyForName(&keyBlob, keyName, uid, TYPE_KEYMASTER_10);
            if (rc != ResponseCode::NO_ERROR) {
                ALOGE("Reading %s failed (%d)", keyName.string(), rc);
                continue;
            }

            hidl_vec<uint8_t> tmpBlob(keystore::blob2hidlVec(keyBlob));
            param.blob = tmpBlob;
        }
    }

    ALOGE("acquireSoterParams() --");
    return newParams;
}
