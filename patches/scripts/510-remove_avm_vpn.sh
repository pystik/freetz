[ "$FREETZ_REMOVE_AVM_VPN" == "y" ] || return 0

echo1 "removing AVM-VPN files"
for files in \
  bin/avmike \
  $(isNeededEntry "libikeapi" "${FILESYSTEM_MOD_DIR}/usr/bin/ctlmgr" "${FILESYSTEM_MOD_DIR}/usr/bin/avm/ctlmgr" || echo 'lib/libikeapi*.so*') \
  lib/libikecrypto*.so* \
  lib/libikeossl*.so* \
  usr/share/ctlmgr/libvpnstat.so \
  usr/www/all/internet/vpn.lua \
  $(find ${FILESYSTEM_MOD_DIR} -iwholename "*usr/www/*/html/*vpn*" -printf "%P\n") \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

echo1 "patching WebUI"
for files in $(grep -rsl '<? setvariable var:showVpn 1 ?>' ${FILESYSTEM_MOD_DIR}); do
	echo2 "patching $files"
	modsed 's/<? setvariable var:showVpn 1 ?>//' "$files"
done

echo1 "patching rc.conf"
modsed "s/CONFIG_VPN=.*$/CONFIG_VPN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
