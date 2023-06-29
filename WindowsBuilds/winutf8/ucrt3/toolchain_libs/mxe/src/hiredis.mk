# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := hiredis
$(PKG)_WEBSITE  := https://github.com/redis/hiredis
$(PKG)_DESCR    := HIREDIS
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.1.0
$(PKG)_CHECKSUM := fe6d21741ec7f3fc9df409d921f47dfc73a4d8ff64f4ac6f1d95f951bf7f53d6
$(PKG)_GH_CONF  := redis/hiredis/releases,v
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_URL      := https://github.com/redis/hiredis/archive/v$($(PKG)_VERSION).tar.gz
$(PKG)_DEPS     := cc openssl

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
            -DBUILD_SHARED_LIBS=$(CMAKE_SHARED_BOOL) \
            -DCMAKE_INSTALL_LIBDIR='$(PREFIX)/$(TARGET)/lib' \
            -DENABLE_SSL=ON \
            -DCMAKE_BUILD_TYPE="Release" \
            -DENABLE_EXAMPLES=OFF \
            -DDISABLE_TESTS=ON \
            -DCMAKE_C_FLAGS="-Wno-int-conversion" \
         '$(1)' 
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' VERBOSE=1
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install VERBOSE=1

    # Test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -pedantic -Wno-sometimes-uninitialized \
        '$(SOURCE_DIR)/test.c' -o '$(PREFIX)/$(TARGET)/bin/test-hiredis.exe' \
        `'$(TARGET)-pkg-config' hiredis --cflags --libs`
endef
