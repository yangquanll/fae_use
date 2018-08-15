ifeq ($(strip $(TRUSTKERNEL_TEE_SUPPORT)), yes)

	#ADDITIONAL_BUILD_PROPERTIES += ro.mtk.trustkernel_tee_support=1

	EXECUTABLE_ARCH := $(if $(filter yes, $(MTK_K64_SUPPORT)),arm64-v8a,armeabi-v7a)

ifeq ($(strip $(PRODUCT_FULL_TREBLE_OVERRIDE)), false) # fota n->o
	COPY_DIR := system/vendor
	TRUSTKERNEL_RC := trustkernel_fota.rc
else
	COPY_DIR := vendor
	TRUSTKERNEL_RC := trustkernel.rc
endif

	PRODUCT_PACKAGES += libteec

	# for Production Line
	PRODUCT_PACKAGES += libpl
	PRODUCT_PACKAGES += libkphproxy
	PRODUCT_PACKAGES += kmsetkey.trustkernel

	# Android TUI service package
	PRODUCT_PACKAGES += TUIService

	# Android build-in services
	PRODUCT_PACKAGES += gatekeeper.trustkernel
ifeq ($(strip $(PRODUCT_FULL_TREBLE_OVERRIDE)), false) # fota n->o
	PRODUCT_PACKAGES += keystore.v1.trustkernel
else
	PRODUCT_PACKAGES += keystore.trustkernel
endif
	# keybox
	PRODUCT_PACKAGES += 6B6579626F785F6372797074

	# Android configuration files
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/bsp/platform/common/scripts/$(TRUSTKERNEL_RC):/vendor/etc/init/trustkernel.rc

	# tee clients and libs
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/client/libs/$(EXECUTABLE_ARCH)/teed:/$(COPY_DIR)/bin/teed

	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/client/libs/arm64-v8a/libteec.so:/$(COPY_DIR)/lib64/libteec.so
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/client/libs/armeabi-v7a/libteec.so:/$(COPY_DIR)/lib/libteec.so


	# KPH ca
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ca/libs/$(EXECUTABLE_ARCH)/kph:/$(COPY_DIR)/bin/kph
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ca/libs/$(EXECUTABLE_ARCH)/pld:/$(COPY_DIR)/bin/pld

	# TAs
	# keymaster_v1
ifeq ($(strip $(PRODUCT_FULL_TREBLE_OVERRIDE)), false) # fota n->o
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ta/9ef77781-7bd5-4e39-965f20f6f211f46b.ta.fota:/$(COPY_DIR)/app/t6/9ef77781-7bd5-4e39-965f20f6f211f46b.ta
else
	# keymaster_v2
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ta/9ef77781-7bd5-4e39-965f20f6f211f46b.ta:/$(COPY_DIR)/app/t6/9ef77781-7bd5-4e39-965f20f6f211f46b.ta
endif

	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ta/2ea702fa-17bc-4752-b3adb2871a772347.ta:/$(COPY_DIR)/app/t6/2ea702fa-17bc-4752-b3adb2871a772347.ta
	# gatekeeper
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ta/02662e8e-e126-11e5-b86d9a79f06e9478.ta:/$(COPY_DIR)/app/t6/02662e8e-e126-11e5-b86d9a79f06e9478.ta
	# ifaa_v2
	#PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ta/8b1e0e41-2636-11e1-ad9e0002a5d5c51b.ta:vendor/app/t6/8b1e0e41-2636-11e1-ad9e0002a5d5c51b.ta
	# kph
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/ta/b46325e6-5c90-8252-2eada8e32e5180d6.ta:/$(COPY_DIR)/app/t6/b46325e6-5c90-8252-2eada8e32e5180d6.ta

	# kph configs
	PRODUCT_COPY_FILES += vendor/mediatek/proprietary/trustzone/trustkernel/source/bsp/platform/common/scripts/kph_cfg/cfg.ini:/$(COPY_DIR)/app/t6/cfg.ini

	VENDOR_TA :=

	# inherit project specific info
	-include vendor/mediatek/proprietary/trustzone/trustkernel/source/build/$(MTK_TARGET_PROJECT)/device_project.mk

	include vendor/mediatek/proprietary/trustzone/trustkernel/source/build/copy_vendor_ta.mk
endif
