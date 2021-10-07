FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} += "backend-ready"

SRC_URI += "\
    file://doma-vdevices.cfg \
    file://doma-set-root \
"

FILES_${PN} += " \
    ${libdir}/xen/bin/doma-set-root \
"

python () {
    for pair in d.getVar('XT_GUEST_NETWORK_DOMA', True).split(';'):
        key, value = pair.split('=')
        if key == 'mac':
            d.setVar('DOMA_NET_MAC', value)
}

do_install_append() {
    cat ${WORKDIR}/doma-vdevices.cfg >> ${D}${sysconfdir}/xen/doma.cfg
    sed -i 's/MAC_FOR_DOMAIN/"${DOMA_NET_MAC}"/" ${D}${sysconfdir}/xen/doma.cfg

    # Install doma-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/doma-set-root ${D}${libdir}/xen/bin

    # Call doma-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/doma.service
    echo "ExecStartPre=${libdir}/xen/bin/doma-set-root" >> ${D}${systemd_unitdir}/system/doma.service
}
