###################################################################
# Include Files Directery
###################################################################

#include $(D_ROOT)/mtk_cust.mak

###################################################################
# Using GCC
###################################################################

CROSS_COMPILE = arm-linux-androideabi-

AS	= $(CROSS_COMPILE)as
LD	= $(CROSS_COMPILE)ld
CC	= $(CROSS_COMPILE)gcc
CPP	= $(CC)-E
AR	= $(CROSS_COMPILE)ar
NM	= $(CROSS_COMPILE)nm
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
RANLIB	= $(CROSS_COMPILE)RANLIB
THUMB_MODE = TRUE


###################################################################
# Initialize GCC Compile Parameter
###################################################################
DEFINE           = -D$(MTK_PLATFORM)
OBJCFLAGS 	 = --gap-fill=0xff
AFLAGS_DEBUG 	 = -Wa,-gstabs,
STRIP_SYMBOL	 = -fdata-sections -ffunction-sections
INCLUDE_FILE = $(INCLUDE_FILE_COMMON)
INCLUDE_FILE += \
    -I$(EMIGEN_OUT)/inc \
    -I$(MTK_PATH_CUSTOM)/inc \
    -I$(D_ROOT)/custom/common/inc \
    -I$(D_ROOT)/inc/$(_CHIP) \
    -I$(MTK_ROOT_CUSTOM)/$(TARGET)/common \
    -I$(MTK_ROOT_CUSTOM)/kernel/dct \
    -I$(MTK_ROOT_OUT)/PTGEN/common \
    -I$(MTK_ROOT_OUT)/NANDGEN/common \
    -I$(PTGEN_OUT)/inc

ifeq ("$(CFG_BOOT_DEV)", "BOOTDEV_NAND")
INCLUDE_FILE    += \
    -I$(MTK_PATH_PLATFORM)/src/drivers/inc/ptgen
endif

ifeq ($(CFG_MICROTRUST_TEE_SUPPORT),1)
INCLUDE_FILE    += \
    -I$(MTK_PATH_PLATFORM)/src/security/trustzone/kdflib/inc
endif

###################################################################
# GCC Compile Options
###################################################################

ifeq ($(CREATE_SEC_LIB),TRUE)

INCLUDE_FILE     +=  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/ \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/inc \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/crypto\
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/inc \

########
# TZCC
########
INCLUDE_FILE     +=  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/crypto_driver/dsc \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/shared/include/pal/no_os  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/shared/include/sbrom \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/shared/include/proj/ssi64 \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/shared/include/pal \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/platform/common/tz  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/secure_boot_gen  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/crys/sym/driver/  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/host/src/sbromlib  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/platform/pal/dx_linux  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/shared/include  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/shared/hw/include  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/host/src/ssi4tzlib  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/platform/pal  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/crypto_driver  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/util  \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/platform/hal/hal_host/dsc \
    -I$(MTK_PATH_PLATFORM)/src/secure_lib/src/platform/$(MTK_PLATFORM)/src/tzcc/codesafe/src/secure_boot/platform/hal 
endif

ifeq ($(CREATE_DEVINFO_LIB),TRUE)
INCLUDE_FILE	 +=  \
	-I$(MTK_PATH_PLATFORM)/src/devinfo_lib/ \
	-I$(MTK_PATH_PLATFORM)/src/devinfo_lib/inc \
	-I$(MTK_PATH_PLATFORM)/src/devinfo_lib/src/platform/$(MTK_PLATFORM)/inc
endif

ifneq ($(filter TRUE,$(CREATE_SEC_LIB) $(CREATE_DEVINFO_LIB)),)
# if it's security.lib, we must remove gcc debug message
C_OPTION	 := -gdwarf-2 -Os -fdata-sections -ffunction-sections -fno-strict-aliasing -fno-common -ffixed-r8 -fno-builtin -ffreestanding -pipe -mno-thumb-interwork -Wstrict-prototypes -march=armv7-a $(DEFINE) -c $(INCLUDE_FILE) -msoft-float -D__ASSEMBLY__  -DPRELOADER_HEAP -mno-unaligned-access
C_OPTION_OPTIMIZE	 := -Os -fdata-sections -ffunction-sections -fno-strict-aliasing -fno-common -ffixed-r8 -fno-builtin -ffreestanding -pipe -mno-thumb-interwork -Wstrict-prototypes -march=armv7-a $(DEFINE) -c $(INCLUDE_FILE) -msoft-float -D__ASSEMBLY__  -DPRELOADER_HEAP -mno-unaligned-access
AFLAGS 		 := -c -march=armv7-a -g
AFLAGS_OPTIMIZE	 := -c -march=armv7-a -g

else

C_OPTION	    := -gdwarf-2 -Os $(STRIP_SYMBOL) -fno-strict-aliasing -fno-common -ffixed-r8 -fno-builtin -ffreestanding -pipe -Wstrict-prototypes -march=armv7-a $(DEFINE) -c $(INCLUDE_FILE) -msoft-float -D__ASSEMBLY__ -g -mno-unaligned-access
C_OPTION_OPTIMIZE   := -Os $(STRIP_SYMBOL) -fno-strict-aliasing -fno-common -ffixed-r8 -fno-builtin -ffreestanding -pipe -Wstrict-prototypes -march=armv7-a $(DEFINE) -c $(INCLUDE_FILE) -msoft-float -D__ASSEMBLY__ -g -mno-unaligned-access
AFLAGS 		 := -c -march=armv7-a -g
AFLAGS_OPTIMIZE	 := -c -march=armv7-a -g
endif

ifeq ($(THUMB_MODE),TRUE)
#thumb
C_OPTION            += -mthumb-interwork -mthumb
C_OPTION_OPTIMIZE   += -mthumb-interwork -mthumb
else
C_OPTION	    += -mno-thumb-interwork
C_OPTION_OPTIMIZE   += -mno-thumb-interwork
endif

#priority: mode > project config > cust > default
include $(MTK_PATH_PLATFORM)/default.mak
include ${MTK_ROOT_CUSTOM}/${TARGET}/cust_bldr.mak
PROJECT_CONFIGS := $(MTK_ROOT_CUSTOM)/$(MTK_PROJECT)/$(MTK_PROJECT).mk
include $(PROJECT_CONFIGS)

ifdef PL_MODE
C_OPTION += -D$(PL_MODE)
C_OPTION_OPTIMIZE += -D$(PL_MODE)
include $(MTK_PATH_PLATFORM)/mode/$(PL_MODE).mak
endif

ifeq ("$(MTK_SECURITY_SW_SUPPORT)","yes")
	C_OPTION += -DMTK_SECURITY_SW_SUPPORT
endif

export QIHU_EXTEND_SECURE_BOOT_SUPPORT=yes
ifeq ("$(QIHU_EXTEND_SECURE_BOOT_SUPPORT)","yes")
   C_OPTION += -DQIHU_EXTEND_SECURE_BOOT_SUPPORT
endif

ifeq ($(strip $(TARGET_BUILD_VARIANT)),eng)
    C_OPTION += -DTARGET_BUILD_VARIANT_ENG
endif

ifeq ("$(MTK_EMMC_SUPPORT)","yes")
    C_OPTION += -DMTK_EMMC_SUPPORT
endif

include $(MTK_PATH_PLATFORM)/feature.mak

MTK_CDEFS := $(PL_MTK_CDEFS)
MTK_ADEFS := $(PL_MTK_ADEFS)

# make unmark for PL booting time profiling
#C_OPTION += -DPL_PROFILING
C_OPTION += $(MTK_CFLAGS) $(MTK_CDEFS) $(MTK_INC)
AFLAGS   += $(MTK_AFLAGS)

ifeq ("$(CFG_FUNCTION_PICACHU_SUPPORT)", "1")
AFLAGS   += -mfpu=neon-vfpv4 -mfloat-abi=softfp
endif
###################################################################
# gcc link descriptor
###################################################################

ifeq ($(findstring fpga, $(TARGET)),fpga)
LDSCRIPT	:= $(MTK_PATH_PLATFORM)/link_descriptor_fpga.ld
else
LDSCRIPT	:= $(MTK_PATH_PLATFORM)/link_descriptor.ld
ifeq ($(CFG_PRELOADER_EXTENSION), 1)
LDSCRIPT	:= $(MTK_PATH_PLATFORM)/link_descriptor_ext.ld
endif #($(CFG_PRELOADER_EXTENSION), 1)
ifdef PL_MODE
ifeq ($(strip $(PL_MODE)), TRNG_R1)
LDSCRIPT	:= $(MTK_PATH_PLATFORM)/link_descriptor_trng_r1.ld
endif
ifeq ($(strip $(PL_MODE)), TRNG_R2)
LDSCRIPT	:= $(MTK_PATH_PLATFORM)/link_descriptor_trng_r2.ld
endif
ifeq ($(strip $(PL_MODE)), AS_DA)
LDSCRIPT	:= $(MTK_PATH_PLATFORM)/link_descriptor_as_da.ld
endif
endif #PL_MODE
endif

LINKFILE	:= $(LD)
LINK		:= $(LINKFILE) -Bstatic -T $(LDSCRIPT) --gc-sections

###################################################################
# Object File
###################################################################

export All_OBJS
