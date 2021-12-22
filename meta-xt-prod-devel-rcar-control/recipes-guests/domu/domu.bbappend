FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

RDEPENDS_${PN} = "backend-ready"
SRC_URI += "\
    file://domu-vdevices.cfg \
    file://domu-pvcamera.cfg \
    file://domu-set-root \
"

FILES_${PN} += " \
    ${libdir}/xen/bin/domu-set-root \
"

python () {
    for pair in d.getVar('XT_GUEST_NETWORK_DOMU', True).split(';'):
        key, value = pair.split('=')
        if key == 'mac':
            d.setVar('DOMU_NET_MAC', value)
}

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domu.cfg"

do_install_append() {
    cat ${WORKDIR}/domu-vdevices.cfg >> ${CFG_FILE}
    sed -i 's/MAC_FOR_DOMAIN/"${DOMU_NET_MAC}"/" ${CFG_FILE}

    if ${@bb.utils.contains('DISTRO_FEATURES', 'pvcamera', 'true', 'false', d)}; then
        cat ${WORKDIR}/domu-pvcamera.cfg >> ${CFG_FILE}
        # Update GUEST_DEPENDENCIES by adding camerabe after sndbe
        sed -i 's/\<sndbe\>/& camerabe/' ${D}${sysconfdir}/init.d/guest_domu
        echo "[Unit]" >> ${D}${systemd_unitdir}/system/domu.service
        echo "Requires=backend-ready@camerabe.service" >> ${D}${systemd_unitdir}/system/domu.service
        echo "After=backend-ready@camerabe.service" >> ${D}${systemd_unitdir}/system/domu.service
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'virtio', 'true', 'false', d)}; then
        sed -i 's/3, xvda1/3, xvda1, virtio/' ${CFG_FILE}

        # Update root by changing xvda1 to vda
        sed -i 's/root=\/dev\/xvda1/root=\/dev\/vda/' ${CFG_FILE}

        # Update GUEST_DEPENDENCIES by adding virtio-disk after sndbe
        echo "[Unit]" >> ${D}${systemd_unitdir}/system/domu.service
        echo "Requires=backend-ready@virtio.service" >> ${D}${systemd_unitdir}/system/domu.service
        echo "After=backend-ready@virtio.service" >> ${D}${systemd_unitdir}/system/domu.service
    fi

    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domu-set-root ${D}${libdir}/xen/bin

    # Call domu-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domu.service
    echo "ExecStartPre=${libdir}/xen/bin/domu-set-root" >> ${D}${systemd_unitdir}/system/domu.service
}
