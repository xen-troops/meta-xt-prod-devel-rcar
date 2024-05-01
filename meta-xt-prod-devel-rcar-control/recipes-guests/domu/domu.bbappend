FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

RDEPENDS:${PN} += " backend-ready"
SRC_URI += "\
    file://domu-vdevices.cfg \
    file://domu-pvcamera.cfg \
    file://virtio.cfg \
    file://domu-vdevices-virtio.cfg \
    file://domu-vdevices-virtio-nogsx.cfg \
    file://domu-set-root \
    file://domu-set-root.conf \
    file://domu-set-root-virtio.conf \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', 'file://sndbe-backend.conf', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', 'file://displbe-backend.conf', '', d)} \
    file://gsx-common.cfg \
"

FILES:${PN} += " \
    ${libdir}/xen/bin/domu-set-root \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', \
    '${sysconfdir}/systemd/system/domu.service.d/domu-set-root-virtio.conf', \
    '${sysconfdir}/systemd/system/domu.service.d/domu-set-root.conf', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', '${sysconfdir}/systemd/system/domu.service.d/sndbe-backend.conf', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', '${sysconfdir}/systemd/system/domu.service.d/displbe-backend.conf', '', d)} \
"

# It is used a lot in the do_install, so variable will be handy
CFG_FILE="${D}${sysconfdir}/xen/domu.cfg"

# This function is used to determine `dtdev` block for GSX.
# Pay attention, that single quote char ' have to be used
# inside `dtdev = []` construction because we will use
# linux's echo command to put multiline string into domu.cfg
python () {
    if d.getVar("XT_DOMU_CONFIG_NAME", True) == "domu-generic-h3-4x2g.cfg":
        d.setVar("GSX_DTDEV",
'''
dtdev = [
    '/soc/gsx_pv0_domu',
    '/soc/gsx_pv1_domu',
    '/soc/gsx_pv2_domu',
    '/soc/gsx_pv3_domu',
]''')

    if d.getVar("XT_DOMU_CONFIG_NAME", True) == "domu-generic-m3-2x4g.cfg":
        d.setVar("GSX_DTDEV",
'''
dtdev = [
    "/soc/gsx_pv0_domu",
    "/soc/gsx_pv1_domu",
]''')
}

do_install:append() {

    if ${@bb.utils.contains('DISTRO_FEATURES', 'pvcamera', 'true', 'false', d)}; then
        cat ${WORKDIR}/domu-pvcamera.cfg >> ${CFG_FILE}
        echo "[Unit]" >> ${D}${systemd_unitdir}/system/domu.service
        echo "Requires=backend-ready@camerabe.service" >> ${D}${systemd_unitdir}/system/domu.service
        echo "After=backend-ready@camerabe.service" >> ${D}${systemd_unitdir}/system/domu.service
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'true', 'false', d)}; then
        cat ${WORKDIR}/virtio.cfg >> ${CFG_FILE}
        if ${@bb.utils.contains('MACHINE_FEATURES', 'gsx', 'true', 'false', d)}; then
            cat ${WORKDIR}/domu-vdevices-virtio.cfg >> ${CFG_FILE}
        else
            cat ${WORKDIR}/domu-vdevices-virtio-nogsx.cfg >> ${CFG_FILE}
        fi
    else
        cat ${WORKDIR}/domu-vdevices.cfg >> ${CFG_FILE}
        if ${@bb.utils.contains('MACHINE_FEATURES', 'gsx', 'true', 'false', d)}; then
            cat ${WORKDIR}/gsx-common.cfg >> ${CFG_FILE}
            sed -i "s/cma=32M/cma=256M pvrsrvkm.DriverMode=1/g" ${CFG_FILE}
            echo "${GSX_DTDEV}" >> ${CFG_FILE}
        fi
    fi

    # Install domu-set-root script
    install -d ${D}${libdir}/xen/bin
    install -m 0744 ${WORKDIR}/domu-set-root ${D}${libdir}/xen/bin
    install -d ${D}${sysconfdir}/systemd/system/domu.service.d

    if ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/domu-set-root-virtio.conf ${D}${sysconfdir}/systemd/system/domu.service.d
    else
        install -m 0644 ${WORKDIR}/domu-set-root.conf ${D}${sysconfdir}/systemd/system/domu.service.d
    fi

    # Install drop-in file to add dependencies on sndbe and displbe
    # Directory is installed above for domu-set-root.conf
    if ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/sndbe-backend.conf ${D}${sysconfdir}/systemd/system/domu.service.d
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'displbe', 'true', 'false', d)}; then
        install -m 0644 ${WORKDIR}/displbe-backend.conf ${D}${sysconfdir}/systemd/system/domu.service.d
    fi
}
