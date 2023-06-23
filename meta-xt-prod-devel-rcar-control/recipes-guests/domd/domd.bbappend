FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://domd-set-root \
"

FILES:${PN} += " \
    ${libdir}/xen/bin/domd-set-root \
"

DOMD_RAM_SIZE:mem8gb = "2048"
DOMD_RAM_SIZE:mem4gb = "1024"
DOMD_RAM_SIZE:mem8gb:enable_android:enable_virtio = "3072"

do_install:append() {

    echo "" >> ${D}${sysconfdir}/xen/domd.cfg
    echo "# Initial memory allocation (MB)" >> ${D}${sysconfdir}/xen/domd.cfg
    echo "memory = ${DOMD_RAM_SIZE}" >> ${D}${sysconfdir}/xen/domd.cfg

    # Install domd-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domd-set-root ${D}${libdir}/xen/bin

    # Call domd-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domd.service
    echo "ExecStartPre=${libdir}/xen/bin/domd-set-root" >> ${D}${systemd_unitdir}/system/domd.service
}
