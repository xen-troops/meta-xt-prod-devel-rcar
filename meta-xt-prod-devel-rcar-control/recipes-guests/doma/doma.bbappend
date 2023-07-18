FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} += "backend-ready"

SRC_URI += "\
    file://doma-vdevices.cfg \
    file://doma-set-root \
    file://doma-set-root.conf \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', 'file://sndbe-backend.conf', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', 'file://displbe-backend.conf', '', d)} \
"

FILES:${PN} += " \
    ${libdir}/xen/bin/doma-set-root \
    ${sysconfdir}/systemd/system/doma.service.d/doma-set-root.conf \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', '${sysconfdir}/systemd/system/doma.service.d/sndbe-backend.conf', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', '${sysconfdir}/systemd/system/doma.service.d/displbe-backend.conf', '', d)} \
"

DOMA_RAM_SIZE:mem8gb:enable_android = "5120"
DOMA_RAM_SIZE:mem8gb:enable_android:enable_virtio = "4096"

do_install:append() {

    echo "" >> ${D}${sysconfdir}/xen/doma.cfg
    echo "# Initial memory allocation (MB)" >> ${D}${sysconfdir}/xen/doma.cfg
    echo "memory = ${DOMA_RAM_SIZE}" >> ${D}${sysconfdir}/xen/doma.cfg

    cat ${WORKDIR}/doma-vdevices.cfg >> ${D}${sysconfdir}/xen/doma.cfg

    # Install doma-set-root script and the drop-in file to run it
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/doma-set-root ${D}${libdir}/xen/bin
    install -d ${D}${sysconfdir}/systemd/system/doma.service.d
    install -m 0644 ${WORKDIR}/doma-set-root.conf ${D}${sysconfdir}/systemd/system/doma.service.d

    # Install drop-in file to add dependencies on sndbe and displbe
    # Directory is installed above for doma-set-root.conf

    if ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/sndbe-backend.conf ${D}${sysconfdir}/systemd/system/doma.service.d
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/displbe-backend.conf ${D}${sysconfdir}/systemd/system/doma.service.d
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'false', 'true', d)}; then
        echo "device_tree = \"/usr/lib/xen/boot/doma.dtb\"" >> ${D}${sysconfdir}/xen/doma.cfg
    fi
}
