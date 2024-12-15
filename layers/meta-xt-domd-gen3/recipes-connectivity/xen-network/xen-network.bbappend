FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://61-vif-emu1.network \
"

S = "${WORKDIR}"

FILES:${PN} += " \
    ${sysconfdir}/systemd/network/61-vif-emu1.network \
"

XT_DOMA_FORWARD_DESTINATION = "192.168.2.4"

do_install:append() {
    install -d ${D}${sysconfdir}/systemd/network/
    install -m 0644 ${WORKDIR}/61-vif-emu1.network ${D}${sysconfdir}/systemd/network
}
