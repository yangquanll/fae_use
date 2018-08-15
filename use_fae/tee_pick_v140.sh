TARGET_BOARD_PLATFORM=$1
MTK_TARGET_PROJECT=$2
ALPS_ROOT=$3

if test -z "$TARGET_BOARD_PLATFORM" | test -z "$MTK_TARGET_PROJECT" | test -z "$ALPS_ROOT"
then 
    echo
    echo USAGE
    echo -e "\x1B[01;96m "$0 [TARGET_BOARD_PLATFORM] [MTK_TARGET_PROJECT] [alps path]" \x1B[0m"
    echo
    echo   If unsure what the true argument is, you can get it by executing the following
    echo   "command under alps root path (ensure you executed source & lunch before):"
    echo
    echo   get_build_var TARGET_BOARD_PLATFORM
    echo   get_build_var MTK_TARGET_PROJECT
    echo
    exit
fi

if test ! -d $ALPS_ROOT
then
    echo
    echo No alps root path found!
    echo
    exit 1
fi

ALL_6737M="
device/mediatek/build/build/tools/ptgen/MT6737M/partition_table_MT6737M.xls
device/mediatek/build/build/tools/ptgen/MT6737M/partition_table_MT6737T.xls
device/mediatek/mt6735/device.mk
device/mediatek/mt6735/factory_init.rc
device/mediatek/mt6735/meta_init.rc
device/mediatek/mt6735/ueventd.mt6735.rc
device/mediatek/sepolicy/bsp/non_plat/file_contexts
device/mediatek/sepolicy/bsp/non_plat/property_contexts
device/mediatek/sepolicy/bsp/non_plat/tkcore_daemon.te
device/mediatek/sepolicy/bsp/non_plat/untrusted_app.te
`cd ${ALPS_ROOT};find $(find device/ -maxdepth 2 -name ${MTK_TARGET_PROJECT}) -name ProjectConfig.mk; cd ..`
kernel-3.18/arch/arm64/boot/dts/mt6735.dts
kernel-3.18/arch/arm64/boot/dts/mt6735m.dts
kernel-3.18/arch/arm64/configs/${MTK_TARGET_PROJECT}_debug_defconfig
kernel-3.18/arch/arm64/configs/${MTK_TARGET_PROJECT}_defconfig
kernel-3.18/drivers/misc/mediatek/Kconfig
kernel-3.18/drivers/misc/mediatek/Makefile
kernel-3.18/drivers/misc/mediatek/tkcore
kernel-3.18/drivers/mmc/host/mediatek/Makefile
kernel-3.18/drivers/mmc/host/mediatek/emmc_rpmb.c
kernel-3.18/drivers/spi/mediatek/mt6735/Makefile
kernel-3.18/drivers/spi/mediatek/mt6735/spi.c
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/main.c
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/rules.mk
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/tkcore_wp.c
vendor/mediatek/proprietary/bootable/bootloader/lk/platform/mt6735/rules.mk
vendor/mediatek/proprietary/bootable/bootloader/lk/project/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/${MTK_TARGET_PROJECT}/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/${MTK_TARGET_PROJECT}/cust_bldr.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6735/default.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6735/feature.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6735/src/core/main.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6735/src/security/trustzone/inc/tz_tkcore.h
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6735/src/security/trustzone/makefile
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6735/src/security/trustzone/tz_init.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6735/src/security/trustzone/tz_tkcore.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/preloader.patch
vendor/mediatek/proprietary/hardware/meta/common/Android.mk
vendor/mediatek/proprietary/hardware/meta/common/inc/TrustkernelExternalCommand.h
vendor/mediatek/proprietary/hardware/meta/common/inc/TrustkernelExternalPrivate.h
vendor/mediatek/proprietary/hardware/meta/common/src/FtModule.cpp
vendor/mediatek/proprietary/hardware/meta/common/src/TrustkernelExternal.cpp
vendor/mediatek/proprietary/trustzone/atf/v1.0/Makefile
vendor/mediatek/proprietary/trustzone/atf/v1.0/include/bl32/tkcore/tkcore.h
vendor/mediatek/proprietary/trustzone/atf/v1.0/plat/mt6735/plat_tkcore.c
vendor/mediatek/proprietary/trustzone/atf/v1.0/plat/mt6735/platform.mk
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/teesmc.h
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/teesmc_tkcored.h
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/tkcored.mk
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/tkcored_common.c
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/tkcored_helpers.S
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/tkcored_main.c
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/tkcored_pm.c
vendor/mediatek/proprietary/trustzone/atf/v1.0/services/spd/tkcored/tkcored_private.h
vendor/mediatek/proprietary/trustzone/custom/build/Android.mk
vendor/mediatek/proprietary/trustzone/custom/build/common_config.mk
vendor/mediatek/proprietary/trustzone/custom/build/fast_build.sh
vendor/mediatek/proprietary/trustzone/custom/build/project/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/trustzone/custom/build/trustkernel_config.mk
vendor/mediatek/proprietary/trustzone/trustkernel/source
"
ALL_6580="
`cd ${ALPS_ROOT};find $(find device/ -maxdepth 2 -name ${MTK_TARGET_PROJECT}) -name ProjectConfig.mk; cd ..`
device/mediatek/build/build/tools/ptgen/MT6580/partition_table_MT6580.xls
device/mediatek/mt6580/device.mk
device/mediatek/mt6580/factory_init.rc
device/mediatek/mt6580/meta_init.rc
device/mediatek/mt6580/ueventd.mt6580.rc
device/mediatek/sepolicy/bsp/non_plat/file_contexts
device/mediatek/sepolicy/bsp/non_plat/property_contexts
device/mediatek/sepolicy/bsp/non_plat/tkcore_daemon.te
device/mediatek/sepolicy/bsp/non_plat/untrusted_app.te
kernel-3.18/arch/arm/Kconfig
kernel-3.18/arch/arm/boot/dts/mt6580.dts
kernel-3.18/arch/arm/configs/${MTK_TARGET_PROJECT}_debug_defconfig
kernel-3.18/arch/arm/configs/${MTK_TARGET_PROJECT}_defconfig
kernel-3.18/drivers/misc/mediatek/Kconfig
kernel-3.18/drivers/misc/mediatek/Makefile
kernel-3.18/drivers/misc/mediatek/base/power/cpuidle_v1/Makefile
kernel-3.18/drivers/misc/mediatek/base/power/cpuidle_v1/mt_cpuidle.c
kernel-3.18/drivers/misc/mediatek/base/power/mt6580/Makefile
kernel-3.18/drivers/misc/mediatek/base/power/mt6580/hotplug.c
kernel-3.18/drivers/misc/mediatek/base/power/mt6580/mt-smp.c
kernel-3.18/drivers/misc/mediatek/mach/mt6580/ca7_timer.c
kernel-3.18/drivers/misc/mediatek/tkcore/
kernel-3.18/drivers/mmc/host/mediatek/Makefile
kernel-3.18/drivers/mmc/host/mediatek/emmc_rpmb.c
kernel-3.18/drivers/spi/mediatek/mt6580/Makefile
kernel-3.18/drivers/spi/mediatek/mt6580/spi.c
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/main.c
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/rules.mk
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/tkcore_wp.c
vendor/mediatek/proprietary/bootable/bootloader/lk/platform/mt6580/rules.mk
vendor/mediatek/proprietary/bootable/bootloader/lk/project/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/bootable/bootloader/preloader/Makefile
vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/${MTK_TARGET_PROJECT}/cust_bldr.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/${MTK_TARGET_PROJECT}/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/default.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/feature.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/src/core/main.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/src/core/partition.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/src/security/makefile
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/src/security/trustzone/inc/tz_tkcore.h
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/src/security/trustzone/makefile
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/src/security/trustzone/tz_init.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6580/src/security/trustzone/tz_tkcore.c
vendor/mediatek/proprietary/hardware/meta/common/Android.mk
vendor/mediatek/proprietary/hardware/meta/common/inc/TrustkernelExternalCommand.h
vendor/mediatek/proprietary/hardware/meta/common/inc/TrustkernelExternalPrivate.h
vendor/mediatek/proprietary/hardware/meta/common/src/FtModule.cpp
vendor/mediatek/proprietary/hardware/meta/common/src/TrustkernelExternal.cpp
vendor/mediatek/proprietary/trustzone/custom/build/Android.mk
vendor/mediatek/proprietary/trustzone/custom/build/common_config.mk
vendor/mediatek/proprietary/trustzone/custom/build/fast_build.sh
vendor/mediatek/proprietary/trustzone/custom/build/project/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/trustzone/custom/build/trustkernel_config.mk
vendor/mediatek/proprietary/trustzone/trustkernel/source/
"
ALL_6739="
device/mediatek/build/build/tools/ptgen/MT6739/partition_table_MT6739.xls
device/mediatek/mt6739/device.mk
device/mediatek/mt6739/factory_init.rc
device/mediatek/mt6739/meta_init.rc
device/mediatek/mt6739/ueventd.mt6739.emmc.rc
device/mediatek/sepolicy/bsp/non_plat/file_contexts
device/mediatek/sepolicy/bsp/non_plat/property_contexts
device/mediatek/sepolicy/bsp/non_plat/tkcore_daemon.te
device/mediatek/sepolicy/bsp/non_plat/untrusted_app.te
`cd ${ALPS_ROOT};find $(find device/ -maxdepth 2 -name ${MTK_TARGET_PROJECT}) -name ProjectConfig.mk; cd ..`
kernel-4.4/arch/arm/boot/dts/mt6739.dts
kernel-4.4/arch/arm/configs/${MTK_TARGET_PROJECT}_debug_defconfig
kernel-4.4/arch/arm/configs/${MTK_TARGET_PROJECT}_defconfig
kernel-4.4/drivers/char/rpmb/Makefile
kernel-4.4/drivers/char/rpmb/rpmb-mtk.c
kernel-4.4/drivers/misc/mediatek/Kconfig
kernel-4.4/drivers/misc/mediatek/Makefile
kernel-4.4/drivers/misc/mediatek/tkcore/
kernel-4.4/drivers/spi/Makefile
kernel-4.4/drivers/spi/spi-mt65xx.c
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/main.c
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/rules.mk
vendor/mediatek/proprietary/bootable/bootloader/lk/kernel/tkcore_wp.c
vendor/mediatek/proprietary/bootable/bootloader/lk/platform/mt6739/rules.mk
vendor/mediatek/proprietary/bootable/bootloader/lk/project/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/bootable/bootloader/preloader/Makefile
vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/${MTK_TARGET_PROJECT}/cust_bldr.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/custom/${MTK_TARGET_PROJECT}/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/default.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/feature.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/makefile.mak
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/src/core/main.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/src/security/trustzone/inc/tz_tkcore.h
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/src/security/trustzone/makefile
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/src/security/trustzone/tz_init.c
vendor/mediatek/proprietary/bootable/bootloader/preloader/platform/mt6739/src/security/trustzone/tz_tkcore.c
vendor/mediatek/proprietary/hardware/meta/common/Android.mk
vendor/mediatek/proprietary/hardware/meta/common/inc/TrustkernelExternalCommand.h
vendor/mediatek/proprietary/hardware/meta/common/inc/TrustkernelExternalPrivate.h
vendor/mediatek/proprietary/hardware/meta/common/src/FtModule.cpp
vendor/mediatek/proprietary/hardware/meta/common/src/TrustkernelExternal.cpp
vendor/mediatek/proprietary/trustzone/atf/v1.3/Makefile
vendor/mediatek/proprietary/trustzone/atf/v1.3/include/bl32/tkcore/tkcore.h
vendor/mediatek/proprietary/trustzone/atf/v1.3/plat/mediatek/common/log.c
vendor/mediatek/proprietary/trustzone/atf/v1.3/plat/mediatek/mt6739/drivers/devapc/devapc.c
vendor/mediatek/proprietary/trustzone/atf/v1.3/plat/mediatek/mt6739/plat_mt_gic.c
vendor/mediatek/proprietary/trustzone/atf/v1.3/plat/mediatek/mt6739/plat_tkcore.c
vendor/mediatek/proprietary/trustzone/atf/v1.3/plat/mediatek/mt6739/platform.mk
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/teesmc.h
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/teesmc_tkcored.h
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/tkcored.mk
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/tkcored_common.c
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/tkcored_helpers.S
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/tkcored_main.c
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/tkcored_pm.c
vendor/mediatek/proprietary/trustzone/atf/v1.3/services/spd/tkcored/tkcored_private.h
vendor/mediatek/proprietary/trustzone/custom/build/Android.mk
vendor/mediatek/proprietary/trustzone/custom/build/common_config.mk
vendor/mediatek/proprietary/trustzone/custom/build/fast_build.sh
vendor/mediatek/proprietary/trustzone/custom/build/project/${MTK_TARGET_PROJECT}.mk
vendor/mediatek/proprietary/trustzone/custom/build/trustkernel_config.mk
vendor/mediatek/proprietary/trustzone/trustkernel/source/
"

if test $TARGET_BOARD_PLATFORM = mt6737
then
    TODO=$ALL_6737M
elif test $TARGET_BOARD_PLATFORM = mt6580
then
    TODO=$ALL_6580
elif test $TARGET_BOARD_PLATFORM = mt6739
then
    TODO=$ALL_6739
else
    echo
    echo No Such $TARGET_BOARD_PLATFORM specified! please Contact fanchuanyong@trustkernel.com
    exit 1
fi

for file in $TODO
do
    rsync -Rr ${ALPS_ROOT}/$file tee_pick/
done
tar czf tee_pick_$TARGET_BOARD_PLATFORM.tar.gz tee_pick/

if test $? = 0
then
    echo ALL Done!
fi
