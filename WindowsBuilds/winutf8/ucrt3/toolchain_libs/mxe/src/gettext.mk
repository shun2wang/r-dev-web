# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := gettext
$(PKG)_WEBSITE  := https://www.gnu.org/software/gettext/
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 0.22
$(PKG)_CHECKSUM := 24e2669b23abf26f9afdbbc3055edeb33879fb36454de80e8e4aadb3dbbe0b96
$(PKG)_SUBDIR   := gettext-$($(PKG)_VERSION)
$(PKG)_FILE     := gettext-$($(PKG)_VERSION).tar.lz
$(PKG)_URL      := https://ftp.gnu.org/gnu/gettext/$($(PKG)_FILE)
$(PKG)_URL_2    := https://ftpmirror.gnu.org/gettext/$($(PKG)_FILE)
# native gettext isn't technically required, but downstream
# cross-packages may need binaries and/or *.m4 files etc.
$(PKG)_DEPS     := cc libiconv $(BUILD)~$(PKG)

$(PKG)_TARGETS       := $(BUILD) $(MXE_TARGETS)
$(PKG)_DEPS_$(BUILD) := libiconv

define $(PKG)_UPDATE
    $(WGET) -q -O- 'https://ftp.gnu.org/gnu/gettext/' | \
    grep 'gettext-' | \
    $(SED) -n 's,.*gettext-\([0-9][^>]*\)\.tar.*,\1,p' | \
    $(SORT) -Vr | \
    head -1
endef

define $(PKG)_BUILD
    cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/gettext-runtime/configure' \
        $(MXE_CONFIGURE_OPTS) \
        --enable-threads=win32 \
        --without-libexpat-prefix \
        --without-libxml2-prefix \
        CONFIG_SHELL=$(SHELL)
    $(MAKE) -C '$(BUILD_DIR)/intl' -j '$(JOBS)'
    $(MAKE) -C '$(BUILD_DIR)/intl' -j 1 install
endef

define $(PKG)_BUILD_$(BUILD)
    # build and install the library
    cd '$(BUILD_DIR)' && $(SOURCE_DIR)/configure \
        $(MXE_CONFIGURE_OPTS)
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(MXE_DISABLE_DOCS)
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install $(MXE_DISABLE_DOCS)
endef
