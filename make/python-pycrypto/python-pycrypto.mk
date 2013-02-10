$(call PKG_INIT_BIN, 2.6)
$(PKG)_SOURCE:=pycrypto-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=88dad0a270d1fe83a39e0467a66a22bb
$(PKG)_SITE:=http://ftp.dlitz.net/pub/dlitz/crypto/pycrypto

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/pycrypto-$($(PKG)_VERSION)

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto/PublicKey/_fastmath.so

$(PKG)_DEPENDS_ON := python gmp

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod, \
		$(PYTHON_PYCRYPTO_DIR), \
		install --prefix=/usr --root=$(abspath $(PYTHON_PYCRYPTO_DEST_DIR)), \
		TARGET_ARCH="$(FREETZ_TARGET_ARCH)", \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR) \
	)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_PYCRYPTO_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycrypto-*.egg-info

$(PKG_FINISH)