diff --git a/base/Android.mk b/base/Android.mk
index ca41494..3b2afd9 100644
--- a/base/Android.mk
+++ b/base/Android.mk
@@ -590,6 +590,9 @@ LOCAL_SRC_FILES += \
 LOCAL_SRC_FILES += \
 	core/java/android/app/IActivityHctController.aidl
 
+LOCAL_SRC_FILES += \
+	../../vendor/mediatek/proprietary/trustzone/trustkernel/source/external/AndroidServices/ifaa/aidl/com/trustkernel/ITrustKernelIfaaService.aidl
+
 # FRAMEWORKS_BASE_JAVA_SRC_DIRS comes from build/core/pathmap.mk
 LOCAL_AIDL_INCLUDES += \
       $(FRAMEWORKS_BASE_JAVA_SRC_DIRS) \
