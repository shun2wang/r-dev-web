# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := intel-tbb
$(PKG)_WEBSITE  := https://www.threadingbuildingblocks.org
$(PKG)_DESCR    := Intel Threading Building Blocks
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 9e219e2
$(PKG)_CHECKSUM := 194eadccc12f90586f17b329315fcb6f8834304e6a6e7724bcd0cb747c3e94ea
$(PKG)_GH_CONF  := wjakob/tbb/branches/master
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    # build and install the library
    cd '$(BUILD_DIR)' && $(TARGET)-cmake '$(SOURCE_DIR)' \
        -DTBB_BUILD_SHARED=$(CMAKE_SHARED_BOOL) \
        -DTBB_BUILD_STATIC=$(CMAKE_STATIC_BOOL) \
        -DTBB_BUILD_TESTS=OFF
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install

    # create pkg-config files
    $(INSTALL) -d '$(PREFIX)/$(TARGET)/lib/pkgconfig'
    (echo 'Name: $(PKG)'; \
     echo 'Version: $($(PKG)_VERSION)'; \
     echo 'Description: intel-tbb'; \
     echo 'Libs: $(addsuffix $(if $(BUILD_STATIC),_static),-ltbb -ltbbmalloc -ltbbmalloc_proxy)';) \
     > '$(PREFIX)/$(TARGET)/lib/pkgconfig/$(PKG).pc'

    # compile test
    '$(TARGET)-g++' -W -Wall \
        '$(SOURCE_DIR)/examples/test_all/fibonacci/Fibonacci.cpp' \
        -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' $(PKG) --cflags --libs`
endef
