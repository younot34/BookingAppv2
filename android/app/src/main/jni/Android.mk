LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := jnielc
LOCAL_SRC_FILES := jnielc.c
LOCAL_CFLAGS := -Werror
LOCAL_LDLIBS := -llog -lGLESv2
include $(BUILD_SHARED_LIBRARY)
