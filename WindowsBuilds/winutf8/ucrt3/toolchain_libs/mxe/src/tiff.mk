# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := tiff
$(PKG)_WEBSITE  := http://simplesystems.org/libtiff/
$(PKG)_DESCR    := LibTIFF
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 4.5.0
$(PKG)_CHECKSUM := dafac979c5e7b6c650025569c5a4e720995ba5f17bc17e6276d1f12427be267c
$(PKG)_SUBDIR   := tiff-$($(PKG)_VERSION)
$(PKG)_FILE     := tiff-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://download.osgeo.org/libtiff/$($(PKG)_FILE)
  # lerc
$(PKG)_DEPS     := cc jpeg libwebp xz zlib zstd libdeflate

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://simplesystems.org/libtiff/' | \
    $(SED) -n 's,.*>v\([0-9][^<]*\)<.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # --enable-lerc
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --without-x \
        LIBS='-lstdc++'

    $(MAKE) -C '$(1)' -j '$(JOBS)' install $(MXE_DISABLE_CRUFT)

    $(SED) -i 's/Requires.private:/Requires.private: lerc/' \
       $(PREFIX)/$(TARGET)/lib/pkgconfig/libtiff-4.pc

    # compile test
    '$(TARGET)-gcc' \
        -W -Wall -Werror -ansi -pedantic \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-$(PKG).exe' \
        `'$(TARGET)-pkg-config' libtiff-4 --cflags --libs`

endef
