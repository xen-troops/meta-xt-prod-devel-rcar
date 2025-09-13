# Reason for this recipe:
# -- The "pack-ipl" component requires "bootparam_sa0.bin" and "cert_header_sa6.bin"
# to have the "-4x2g" suffix.
# -- On "h3ulcb-4x2g-kf" this comes from extra layers, but for the other machines in the YAML the
# suffix was missing.
# -- This recipe adds the required suffix (via ${EXTRA_ATFW_CONF}) so filenames are consistent
# and "pack-ipl" works correctly across all machines.

do_ipl_opt_deploy:append () {
    install -m 0644 ${S}/tools/renesas/rcar_layout_create/bootparam_sa0.bin ${DEPLOY_DIR_IMAGE}/bootparam_sa0-${EXTRA_ATFW_CONF}.bin
    install -m 0644 ${S}/tools/renesas/rcar_layout_create/cert_header_sa6.bin ${DEPLOY_DIR_IMAGE}/cert_header_sa6-${EXTRA_ATFW_CONF}.bin
}
