# vendor/mediatek/proprietary/trustzone/Android.mk
UpperCase = $(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$(1)))))))))))))))))))))))))))
LowerCase = $(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$(1)))))))))))))))))))))))))))

LOCAL_PATH := $(call my-dir)
TRUSTZONE_ROOT_DIR := $(PWD)
TRUSTZONE_CUSTOM_BUILD_PATH := $(LOCAL_PATH)
TRUSTZONE_OUTPUT_PATH := $(PRODUCT_OUT)/trustzone
TRUSTZONE_IMAGE_OUTPUT_PATH := $(TRUSTZONE_OUTPUT_PATH)

$(info MTK_ATF_SUPPORT = $(MTK_ATF_SUPPORT))
$(info MTK_TEE_SUPPORT = $(MTK_TEE_SUPPORT))
$(info MTK_TEE_GP_SUPPORT = $(MTK_TEE_GP_SUPPORT))
$(info MTK_IN_HOUSE_TEE_SUPPORT = $(MTK_IN_HOUSE_TEE_SUPPORT))
$(info TRUSTONIC_TEE_SUPPORT = $(TRUSTONIC_TEE_SUPPORT))
$(info MICROTRUST_TEE_SUPPORT = $(MICROTRUST_TEE_SUPPORT))
$(info TRUSTKERNEL_TEE_SUPPORT = $(TRUSTKERNEL_TEE_SUPPORT))
$(info MTK_GOOGLE_TRUSTY_SUPPORT = $(MTK_GOOGLE_TRUSTY_SUPPORT))
$(info MTK_SOTER_SUPPORT = $(MTK_SOTER_SUPPORT))
$(info MTK_SEC_VIDEO_PATH_SUPPORT = $(MTK_SEC_VIDEO_PATH_SUPPORT))
$(info MTK_WFD_HDCP_TX_SUPPORT = $(MTK_WFD_HDCP_TX_SUPPORT))

ifneq ($(strip $(call LowerCase,$(MTK_PLATFORM))), mt6739) ### Will remove when MT6739 TEE is ready for BRM
ifneq ($(strip $(call LowerCase,$(MTK_PLATFORM))), mt6758) ### Will remove when MT6758 TEE is ready for BRM
ifneq ($(strip $(call LowerCase,$(MTK_PLATFORM))), mt6771) ### Will remove when MT6771 TEE is ready for BRM
ifneq ($(strip $(call LowerCase,$(MTK_PLATFORM))), mt6775) ### Will remove when MT6775 TEE is ready for BRM
$(info RELEASE_BRM = $(RELEASE_BRM))
ifeq ($(strip $(RELEASE_BRM)),yes)
  ifneq ($(strip $(wildcard $(MTK_PATH_SOURCE)/trustzone/trustonic/source/build/platform/$(call LowerCase,$(MTK_PLATFORM))/tee_config.mk)),)
    MTK_TEE_SUPPORT := yes
    TRUSTONIC_TEE_SUPPORT := yes
    ifneq ($(strip $(shell grep MTK_TEE_GP_SUPPORT $(MTK_PATH_SOURCE)/trustzone/trustonic/source/build/platform/$(call LowerCase,$(MTK_PLATFORM))/tee_config.mk)),)
      MTK_TEE_GP_SUPPORT := yes
    endif
    ifneq ($(strip $(shell grep MTK_SEC_VIDEO_PATH_SUPPORT $(MTK_PATH_SOURCE)/trustzone/trustonic/source/build/platform/$(call LowerCase,$(MTK_PLATFORM))/tee_config.mk)),)
      ifneq ($(strip $(call LowerCase,$(MTK_PLATFORM))), mt6763)
        MTK_SEC_VIDEO_PATH_SUPPORT := yes
      endif
    endif
    ifneq ($(strip $(shell grep MTK_WFD_HDCP_TX_SUPPORT $(MTK_PATH_SOURCE)/trustzone/trustonic/source/build/platform/$(call LowerCase,$(MTK_PLATFORM))/tee_config.mk)),)
      MTK_WFD_HDCP_TX_SUPPORT := yes
    endif
  endif
endif
endif
endif
endif
endif

$(info MTK_TEE_SUPPORT = $(MTK_TEE_SUPPORT))
$(info MTK_TEE_GP_SUPPORT = $(MTK_TEE_GP_SUPPORT))
$(info TRUSTONIC_TEE_SUPPORT = $(TRUSTONIC_TEE_SUPPORT))
$(info MTK_SEC_VIDEO_PATH_SUPPORT = $(MTK_SEC_VIDEO_PATH_SUPPORT))
$(info MTK_WFD_HDCP_TX_SUPPORT = $(MTK_WFD_HDCP_TX_SUPPORT))

MTEE_CURR_FO :=
ifeq ($(strip $(MTK_IN_HOUSE_TEE_SUPPORT)),yes)
  ifeq ($(MTK_WVDRM_L1_SUPPORT),yes)
    ifeq ($(MTK_DRM_PLAYREADY_SUPPORT),yes)
      MTEE_CURR_FO := -wvpr
    else
      MTEE_CURR_FO := -wv
    endif
  else
    ifeq ($(MTK_DRM_PLAYREADY_SUPPORT),yes)
      MTEE_CURR_FO := -pr
    else
      MTEE_CURR_FO :=
    endif
  endif

  ifneq ($(wildcard vendor/mediatek/proprietary/trustzone/mtee/source/Android.mk),)

    # source release
    # include vendor/mediatek/proprietary/trustzone/mtee/protect/Android.mk
    TRUSTZONE_INSTALLED_TARGET := $(PRODUCT_OUT)/tee.img
  else
    # binary release
    TRUSTZONE_INSTALLED_TARGET := $(PRODUCT_OUT)/tee.img
    PREBUILT_TRUSTZONE_TARGET := $(PRODUCT_OUT)/tee.img
  endif
else
  ifneq ($(filter yes,$(MTK_ATF_SUPPORT) $(TRUSTKERNEL_TEE_SUPPORT) $(TRUSTONIC_TEE_SUPPORT) $(MICROTRUST_TEE_SUPPORT) $(MTK_GOOGLE_TRUSTY_SUPPORT)),)
    TRUSTZONE_INSTALLED_TARGET := $(PRODUCT_OUT)/tee.img
  endif
endif

.PHONY: trustzone
ifneq ($(PREBUILT_TRUSTZONE_TARGET),)

else

  # ATF
  ifeq ($(strip $(MTK_ATF_SUPPORT)),yes)
include $(TRUSTZONE_CUSTOM_BUILD_PATH)/atf_config.mk
  endif
  # MTEE
  ifeq ($(strip $(MTK_IN_HOUSE_TEE_SUPPORT)),yes)
include $(TRUSTZONE_CUSTOM_BUILD_PATH)/mtee_config.mk
  endif
# TrustKernel
  ifeq ($(strip $(TRUSTKERNEL_TEE_SUPPORT)),yes)
include $(TRUSTZONE_CUSTOM_BUILD_PATH)/trustkernel_config.mk
$(BUILT_TRUSTZONE_TARGET): $(TEE_COMP_IMAGE_NAME)
  endif
  # Trustonic
  ifeq ($(strip $(TRUSTONIC_TEE_SUPPORT)),yes)
include $(TRUSTZONE_CUSTOM_BUILD_PATH)/tee_config.mk
#trustzone: mcDriverDaemon
$(PRODUCT_OUT)/recovery.img: \
	$(TEE_modules_to_install) \
	$(call intermediates-dir-for,EXECUTABLES,mcDriverDaemon)/mcDriverDaemon
  endif
  # Microtrust
  ifeq ($(strip $(MICROTRUST_TEE_SUPPORT)),yes)
include $(TRUSTZONE_CUSTOM_BUILD_PATH)/microtrust_config.mk
  endif
  # Trusty
  ifeq ($(strip $(MTK_GOOGLE_TRUSTY_SUPPORT)),yes)
include $(TRUSTZONE_CUSTOM_BUILD_PATH)/trusty_config.mk
  endif

ifneq ($(wildcard $(TRUSTZONE_IMG_PROTECT_CFG)),)
  my_trustzone_suffix :=
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
ifeq ($(strip $(MTK_IN_HOUSE_TEE_SUPPORT)),yes)
ifneq ($(MTK_PLATFORM_DIR),mt8127) # no svp/atf support for 8127
  my_trustzone_suffix := -wvpr
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
  my_trustzone_suffix := -wv
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
  my_trustzone_suffix := -pr
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
  my_trustzone_suffix := -ota
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
  my_trustzone_suffix := -wvpr-ota
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
  my_trustzone_suffix := -wv-ota
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
  my_trustzone_suffix := -pr-ota
  include $(TRUSTZONE_CUSTOM_BUILD_PATH)/build_trustzone.mk
endif
endif#MTK_IN_HOUSE_TEE_SUPPORT
endif#wildcard

OTA_FO :=
ifeq ($(ATF_MEMBASE),0x43000000)
OTA_FO := -ota
endif

$(TRUSTZONE_INSTALLED_TARGET): $(call intermediates-dir-for,ETC,trustzone$(MTEE_CURR_FO)$(OTA_FO))/trustzone$(MTEE_CURR_FO)$(OTA_FO) $(TRUSTZONE_CUSTOM_BUILD_PATH)/Android.mk
	@echo Copying: $@
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -fp $< $@

endif

ifneq ($(filter yes,$(TRUSTONIC_TEE_SUPPORT) $(MICROTRUST_TEE_SUPPORT)),)
include $(TRUSTZONE_CUSTOM_BUILD_PATH)/hal_config.mk
endif

ifneq ($(TRUSTZONE_INSTALLED_TARGET),)
$(TARGET_OUT_ETC)/tee.img: $(TRUSTZONE_INSTALLED_TARGET) $(TRUSTZONE_CUSTOM_BUILD_PATH)/Android.mk
	@echo Copying: $@
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -f $< $@

trustzone: $(TEE_modules_to_install) $(TEE_modules_to_check) $(TEE_HAL_modules_to_check) $(TARGET_OUT_ETC)/tee.img
trustzone: $(trustzone_images_to_check)
ALL_DEFAULT_INSTALLED_MODULES += $(TEE_modules_to_install) $(TEE_modules_to_check) $(TEE_HAL_modules_to_check) $(TARGET_OUT_ETC)/tee.img
ALL_DEFAULT_INSTALLED_MODULES += $(trustzone_images_to_check)
endif

ifneq ($(PREBUILT_TRUSTZONE_TARGET),)
$(PREBUILT_TRUSTZONE_TARGET): $(TRUSTZONE_IMAGE_OUTPUT_PATH)/bin/tz$(MTEE_CURR_FO)$(OTA_FO).img
	$(hide) mkdir -p $(dir $@)
	$(hide) cp -fp $< $@
endif
