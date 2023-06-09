
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

do_install:append() {
    if echo "${DISTRO_FEATURES}" | grep -q "ivi-shell"; then
        sed -i '/\[core\]/c\\[core\]\nmodules=ivi-controller.so' \
            ${D}/${sysconfdir}/xdg/weston/weston.ini
        sed -e '$a\\' \
            -e '$a\[ivi-shell]' \
            -e '$a\ivi-id-agent-module=ivi-id-agent.so' \
            -i ${D}/${sysconfdir}/xdg/weston/weston.ini
        sed -e '$a\\' \
            -e '$a\[desktop-app-default]' \
            -e '$a\default-surface-id=2000000' \
            -e '$a\default-surface-id-max=2001000' \
            -i ${D}/${sysconfdir}/xdg/weston/weston.ini
    fi
}
