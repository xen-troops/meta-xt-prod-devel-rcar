require xen-source.inc

FILES:${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
    ${libdir}/xen/bin/test-paging-mempool\
"

do_install:append() {
    rm -f ${D}/${libdir}/xen/bin/init-dom0less
    rm -f ${D}/${systemd_unitdir}/system/var-lib-xenstored.mount
    rm -rf ${D}/var
}

FILES:${PN}-xencommons:remove = "\
    "${systemd_unitdir}/system/var-lib-xenstored.mount" \
"

SYSTEMD_SERVICE:${PN}-xencommons:remove = " \
    var-lib-xenstored.mount \
"

# Remove the recommendation for Qemu for non-hvm x86 added in meta-virtualization layer
RRECOMMENDS:${PN}:remove = " qemu"
