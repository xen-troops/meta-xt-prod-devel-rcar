FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://domd-set-root \
    file://domd-set-root.conf \
    file://domd-set-root-virtio.conf \
"

FILES:${PN} += " \
    ${libdir}/xen/bin/domd-set-root \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', \
    '${sysconfdir}/systemd/system/domd.service.d/domd-set-root-virtio.conf', \
    '${sysconfdir}/systemd/system/domd.service.d/domd-set-root.conf', d)} \
"

DOMD_RAM_SIZE:mem8gb = "2048"
DOMD_RAM_SIZE:mem4gb = "1024"
DOMD_RAM_SIZE:mem8gb:enable_android:enable_virtio = "3072"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domd.cfg"

do_install:append() {

    echo "" >> ${CFG_FILE}
    echo "# Initial memory allocation (MB)" >> ${CFG_FILE}
    echo "memory = ${DOMD_RAM_SIZE}" >> ${CFG_FILE}

    # Install domd-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domd-set-root ${D}${libdir}/xen/bin
    install -d ${D}${sysconfdir}/systemd/system/domd.service.d

    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/domd-set-root-virtio.conf ${D}${sysconfdir}/systemd/system/domd.service.d
    else
        install -m 0644 ${WORKDIR}/domd-set-root.conf ${D}${sysconfdir}/systemd/system/domd.service.d
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'true', 'false', d)}; then
        echo "" >> ${CFG_FILE}
        echo "driver_domain = 1" >> ${CFG_FILE}
    fi
}
