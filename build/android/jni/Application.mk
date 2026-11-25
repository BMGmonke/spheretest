# NDK_TOOLCHAIN_VERSION := clang3.8

APP_PLATFORM := android-21
APP_MODULES := minetest
APP_ABI := arm64-v8a
APP_STL := gnustl_static

APP_CPPFLAGS += -fexceptions
APP_GNUSTL_FORCE_CPP_FEATURES := rtti

