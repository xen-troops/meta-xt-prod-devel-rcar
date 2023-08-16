FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} = "backend-ready"
SRC_URI += "\
    file://domu-vdevices.cfg \
    file://domu-pvcamera.cfg \
    file://virtio.cfg \
    file://domu-vdevices-virtio.cfg \
    file://domu-set-root \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', 'file://sndbe-backend.conf', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', 'file://displbe-backend.conf', '', d)} \
    file://pvr-${XT_DOMU_CONFIG_NAME} \
"

FILES:${PN} += " \
    ${libdir}/xen/bin/domu-set-root \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', '${sysconfdir}/systemd/system/domu.service.d/sndbe-backend.conf', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', '${sysconfdir}/systemd/system/domu.service.d/displbe-backend.conf', '', d)} \
"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domu.cfg"

do_install:append() {

    if ${@bb.utils.contains('DISTRO_FEATURES', 'pvcamera', 'true', 'false', d)}; then
        cat ${WORKDIR}/domu-pvcamera.cfg >> ${CFG_FILE}
        echo "[Unit]" >> ${D}${systemd_unitdir}/system/domu.service
        echo "Requires=backend-ready@camerabe.service" >> ${D}${systemd_unitdir}/system/domu.service
        echo "After=backend-ready@camerabe.service" >> ${D}${systemd_unitdir}/system/domu.service
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'true', 'false', d)}; then
        cat ${WORKDIR}/virtio.cfg >> ${CFG_FILE}
        cat ${WORKDIR}/domu-vdevices-virtio.cfg >> ${CFG_FILE}
    else
        cat ${WORKDIR}/domu-vdevices.cfg >> ${CFG_FILE}
        cat ${WORKDIR}/pvr-${XT_DOMU_CONFIG_NAME} >> ${CFG_FILE}
    fi

    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domu-set-root ${D}${libdir}/xen/bin

    if ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/systemd/system/domu.service.d
        install -m 0644 ${WORKDIR}/sndbe-backend.conf ${D}${sysconfdir}/systemd/system/domu.service.d
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', 'true', 'false', d)}; then
        install -d ${D}${sysconfdir}/systemd/system/domu.service.d
        install -m 0644 ${WORKDIR}/displbe-backend.conf ${D}${sysconfdir}/systemd/system/domu.service.d
    fi

    # Call domu-set-root script
    echo "[Service]" >> ${D}${systemd_unitdir}/system/domu.service
    echo "ExecStartPre=${libdir}/xen/bin/domu-set-root" >> ${D}${systemd_unitdir}/system/domu.service
}
