FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "\
    file://domd-set-root \
"

FILES:${PN} += " \
    ${libdir}/xen/bin/domd-set-root \
"

do_install:append() {
    # Install domd-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domd-set-root ${D}${libdir}/xen/bin

    # Call domd-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domd.service
    echo "ExecStartPre=${libdir}/xen/bin/domd-set-root" >> ${D}${systemd_unitdir}/system/domd.service
}
