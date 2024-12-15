XT_DOMA_ETH0_MAC = "02:15:b2:00:00:00"
XT_DOMA_ETH1_MAC = "08:00:27:ff:cb:cf"

do_install:append() {
    # Configure IP addresses for DomA, DomU.
    # MAC addresses are defined in /etc/xen/domX.cfg
    if ${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', 'true', 'false', d)}; then
        echo "interface=vif-emu1" >> ${D}${sysconfdir}/dnsmasq.conf
        echo "dhcp-range=192.168.2.5,192.168.2.10,12h" >> ${D}${sysconfdir}/dnsmasq.conf
        echo "dhcp-host=${XT_DOMA_ETH1_MAC},doma,192.168.2.4,infinite" >> ${D}${sysconfdir}/dnsmasq.conf
    fi

}
