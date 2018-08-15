#
# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := IfaaService
LOCAL_MODULE_TAGS := optional

LOCAL_CFLAGS := -Wall -Wextra -Wno-error=unused-parameter

LOCAL_SHARED_LIBRARIES := \
    libbase \
    libbinder \
    liblog \
    libutils \
	libteec

LOCAL_C_INCLUDES += \
	$(LOCAL_PATH)/include

LOCAL_AIDL_INCLUDES := \
    frameworks/native/aidl/binder \
	$(LOCAL_PATH)/aidl \
	$(LOCAL_PATH)/include

LOCAL_SRC_FILES := \
	aidl/com/trustkernel/ITrustKernelIfaaService.aidl \
	TaClient.cpp \
	TrustKernelIfaad.cpp \
	TrustKernelIfaaService.cpp

LOCAL_INIT_RC := ifaa.rc

include $(BUILD_EXECUTABLE)
