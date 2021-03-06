$(call PKG_INIT_BIN, 1.42.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=a1ec22ef003688dae9f76c74881b22b9
$(PKG)_SITE:=@SF/e2fsprogs

$(PKG)_LIBNAMES_SHORT_ALL := blkid com_err e2p ext2fs ss uuid
$(PKG)_LIBNAMES_SHORT :=
$(PKG)_LIBVERSIONS :=
ifeq ($(strip $(FREETZ_LIB_libblkid)),y)
$(PKG)_LIBNAMES_SHORT += blkid
$(PKG)_LIBVERSIONS += 1.0
endif
ifeq ($(strip $(FREETZ_LIB_libcom_err)),y)
$(PKG)_LIBNAMES_SHORT += com_err
$(PKG)_LIBVERSIONS += 2.1
endif
ifeq ($(strip $(FREETZ_LIB_libe2p)),y)
$(PKG)_LIBNAMES_SHORT += e2p
$(PKG)_LIBVERSIONS += 2.3
endif
ifeq ($(strip $(FREETZ_LIB_libext2fs)),y)
$(PKG)_LIBNAMES_SHORT += ext2fs
$(PKG)_LIBVERSIONS += 2.4
endif
ifeq ($(strip $(FREETZ_LIB_libss)),y)
$(PKG)_LIBNAMES_SHORT += ss
$(PKG)_LIBVERSIONS += 2.0
endif
ifeq ($(strip $(FREETZ_LIB_libuuid)),y)
$(PKG)_LIBNAMES_SHORT += uuid
$(PKG)_LIBVERSIONS += 1.2
endif

ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
$(PKG)_LIBNAMES_LONG	:= $($(PKG)_LIBNAMES_SHORT_ALL:%=lib%.a)
else
$(PKG)_LIBNAMES_LONG := $(join $($(PKG)_LIBNAMES_SHORT:%=lib%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)
endif
$(PKG)_LIBS_BUILD_DIR	:= $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/lib/%)
$(PKG)_LIBS_STAGING_DIR	:= $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)

$(PKG)_MAKE_ALL_EXTRAS	:= && ln -fsT et $($(PKG)_DIR)/lib/com_err

$(PKG)_BINARIES_ALL := \
	e2fsck fsck \
	mke2fs mklost+found \
	tune2fs dumpe2fs chattr lsattr \
	e2image e2undo debugfs logsave \
	badblocks filefrag e2freefrag uuidd uuidgen \
	resize2fs \
	blkid
$(PKG)_BINARIES :=
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2FSCK)),y)
$(PKG)_BINARIES += e2fsck fsck
$(PKG)_MAKE_ALL_EXTRAS += && cp $($(PKG)_DIR)/e2fsck/e2fsck $($(PKG)_DIR)/misc/
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2MAKING)),y)
$(PKG)_BINARIES += mke2fs mklost+found
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2TUNING)),y)
$(PKG)_BINARIES += tune2fs dumpe2fs chattr lsattr
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2DEBUG)),y)
$(PKG)_BINARIES += e2image e2undo debugfs logsave
$(PKG)_MAKE_ALL_EXTRAS += && cp $($(PKG)_DIR)/debugfs/debugfs $($(PKG)_DIR)/misc/
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2FIXING)),y)
$(PKG)_BINARIES += badblocks filefrag e2freefrag uuidd uuidgen
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2RESIZE)),y)
$(PKG)_BINARIES += resize2fs
$(PKG)_MAKE_ALL_EXTRAS += && cp $($(PKG)_DIR)/resize/resize2fs $($(PKG)_DIR)/misc/
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_BLKID)),y)
$(PKG)_BINARIES += blkid
endif
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/misc/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_STATIC

$(PKG)_CONFIGURE_ENV += ac_cv_path_LDCONFIG=$(TARGET_LDCONFIG)
$(PKG)_CONFIGURE_ENV += gt_cv_func_printf_posix=yes

# uClibc-0.9.29 yields yes, 0.9.28 to be evaluated, it's however absolutely safe to say no
$(PKG)_CONFIGURE_ENV += gt_cv_int_divbyzero_sigfpe=no

# silence some warnings
$(PKG)_CONFIGURE_PRE_CMDS += find $(abspath $($(PKG)_DIR)) -type f -name "*.c" \
	-exec $(SED) -i -r -e 's|(\#define (_LARGEFILE(64)?_SOURCE))|\#ifndef \2\n\1\n\#endif|g' \{\} \+ ;

ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
# we don't really build profiled libraries, we just misuse e2fsprogs' profile-target
# to build static libraries with pic-objects inside, s. 010-pic_instead_of_profile.patch
$(PKG)_CONFIGURE_OPTIONS += --enable-profile
else
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-elf-shlibs
endif
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --disable-defrag
$(PKG)_CONFIGURE_OPTIONS += --disable-quota
$(PKG)_CONFIGURE_OPTIONS += --disable-testio-debug

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(E2FSPROGS_DIR) \
		EXTRA_CFLAGS="-ffunction-sections -fdata-sections" \
		EXTRA_LDFLAGS="-Wl,--gc-sections" \
		INFO=true \
		V=1 \
		all \
		$(E2FSPROGS_MAKE_ALL_EXTRAS)

$($(PKG)_LIBS_STAGING_DIR): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%: $($(PKG)_DIR)/lib/%
# ensure no shared/static-pic library from previous builds exists in STAGING_DIR
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
	$(RM) $(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.so*)
else
	$(RM) $(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%_pic.a)
endif
	LIBSUBDIR=`echo $(notdir $@) | $(SED) -r -e 's|^lib||g' -e 's|[.]so[.].*$$||g' -e 's|[.]a$$||g'` \
	&& \
	$(SUBMAKE) -C $(E2FSPROGS_DIR)/lib/$${LIBSUBDIR} \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		STRIP=true \
		LDCONFIG=true \
		INFO=true \
		install \
	&& \
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/$${LIBSUBDIR}.pc

ifneq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)
endif

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/misc/%
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_E2FSPROGS_E2FSCK)"   != "y" ] && echo -e "usr/sbin/fsck.ext2\nusr/sbin/fsck.ext3\nusr/sbin/fsck.ext4\nusr/sbin/fsck.ext4dev" >> $@; \
	[ "$(FREETZ_PACKAGE_E2FSPROGS_E2MAKING)" != "y" ] && echo -e "usr/sbin/mkfs.ext2\nusr/sbin/mkfs.ext3" >> $@; \
	[ "$(FREETZ_PACKAGE_E2FSPROGS_BLKID)"    != "y" ] && echo "sbin/blkid" >> $@; \
	touch $@

ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
$(pkg)-precompiled: $($(PKG)_LIBS_STAGING_DIR) $($(PKG)_BINARIES_TARGET_DIR)
else
$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR)
endif

$(pkg)-clean:
	-$(SUBMAKE) -C $(E2FSPROGS_DIR) clean
	$(RM) \
		$(E2FSPROGS_DIR)/lib/com_err $(E2FSPROGS_DIR)/misc/e2fsck \
		$(E2FSPROGS_DIR)/misc/debugfs $(E2FSPROGS_DIR)/misc/resize2fs
	$(RM) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.so*) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.a) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%_pic.a) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)
	$(RM) -r \
		$(subst com_err,et,$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/%))

$(pkg)-uninstall:
	$(RM) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(E2FSPROGS_TARGET_LIBDIR)/lib%.so*) \
		$(E2FSPROGS_BINARIES_ALL:%=$(E2FSPROGS_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
