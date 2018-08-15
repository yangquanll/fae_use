LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

ifneq (,$(filter 7.0 7.1.1 8.0 8.0.0 8.1.0,$(PLATFORM_VERSION)))
LOCAL_MODULE := keystore.trustkernel
endif

ifneq ($(strip $(PRODUCT_FULL_TREBLE_OVERRIDE)), true)
$(error Keymaster V2 shall not be built on FOTA version of Android $(PLATFORM_VERSION))
endif

LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_VENDOR_MODULE := true
LOCAL_MODULE_OWNER := trustkernel
LOCAL_SRC_FILES := module.cpp
LOCAL_C_INCLUDES := system/security/keystore
LOCAL_CLFAGS = -fvisibility=hidden -Wall -Werror
LOCAL_SHARED_LIBRARIES := \
	libteec \
	libcrypto \
	liblog \
	libcutils \
	libkeystore_binder
LOCAL_MODULE_TAGS := optional
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk

LOCAL_POST_INSTALL_CMD = \
	$(hide) ln -sf $(notdir $(LOCAL_INSTALLED_MODULE)) $(dir $(LOCAL_INSTALLED_MODULE))keystore.$(TARGET_DEVICE).so ; \
	ln -sf $(notdir $(LOCAL_INSTALLED_MODULE)) $(dir $(LOCAL_INSTALLED_MODULE))keystore.$(TARGET_BOARD_PLATFORM).so

include $(BUILD_SHARED_LIBRARY)
