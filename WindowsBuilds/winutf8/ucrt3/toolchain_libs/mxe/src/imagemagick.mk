# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := imagemagick
$(PKG)_WEBSITE  := https://www.imagemagick.org/
$(PKG)_DESCR    := ImageMagick
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 7.1.0-57
$(PKG)_CHECKSUM := e0157354e0282d34968af6686830216b48d175b65720cd9650b4fae5af2f6251
$(PKG)_GH_CONF  := ImageMagick/ImageMagick/tags
$(PKG)_DEPS     := cc bzip2 ffmpeg fftw freetype jasper jpeg lcms liblqr-1 libltdl \
                   libpng libraw openexr openjpeg pthreads tiff zlib librsvg

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
        $(MXE_CONFIGURE_OPTS) \
        --with-x=no \
        --disable-largefile \
        --with-freetype='$(PREFIX)/$(TARGET)/bin/freetype-config' \
        --with-utilities=no \
        --enable-zero-configuration \
        --with-rsvg \
        --with-freetype \
        --with-cairo \
        --without-fontconfig \
        LIBS="`'$(TARGET)-pkg-config' --libs libtiff-4`"

    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' bin_PROGRAMS=
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install bin_PROGRAMS=

    $(SED) -i 's,^\(Libs.private:.* \),\1-lurlmon ,g' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/MagickCore.pc' \
        '$(PREFIX)/$(TARGET)/lib/pkgconfig/MagickCore-7.Q16HDRI.pc'

    '$(TARGET)-g++' -Wall -Wextra -std=gnu++0x \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-imagemagick.exe' \
        `'$(TARGET)-pkg-config' Magick++ --cflags --libs`
endef
