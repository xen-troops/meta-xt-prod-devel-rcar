require xen-source.inc

PACKAGES_append = "\
    ${PN}-test \
"

FILES_${PN}-test = "\
    ${libdir}/xen/bin/test-xenstore \
    ${libdir}/xen/bin/test-resource \
    ${libdir}/xen/bin/test-paging-mempool\
"

RDEPENDS_${PN} += " \
    util-linux-prlimit \
"

do_install_append() {
    rm -f ${D}/${libdir}/xen/bin/init-dom0less
    rm -f ${D}/${systemd_unitdir}/system/var-lib-xenstored.mount
    rm -rf ${D}/var
}

FILES_${PN}-xencommons_remove = "\
    "${systemd_unitdir}/system/var-lib-xenstored.mount" \
"

SYSTEMD_SERVICE_${PN}-xencommons_remove = " \
    var-lib-xenstored.mount \
"
