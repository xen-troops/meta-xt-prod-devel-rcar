require optee.inc

EXTRA_OEMAKE += " CFG_NS_VIRTUALIZATION=y CFG_VIRT_GUEST_COUNT=2"

# Enable Android-specific features if we are building Android guest
ANDROID_EXTRA_OEMAKE = " \
	       CFG_ASN1_PARSER=y \
	       CFG_CORE_MBEDTLS_MPI=y \
	       CFG_RPMB_FS=y \
	       CFG_RPMB_WRITE_KEY=y \
	       CFG_EARLY_TA=y \
	       CFG_IN_TREE_EARLY_TAS=avb/023f8f1a-292a-432b-8fc4-de8471358067 \
	       "

EXTRA_OEMAKE += "${@bb.utils.contains('XT_GUEST_INSTALL', 'doma', '${ANDROID_EXTRA_OEMAKE}', '', d)}"

do_install:append() {
    install -m 644 ${B}/core/tee.srec ${D}${nonarch_base_libdir}/firmware/tee-${MACHINE}.srec
}

do_deploy:append() {
    if [ -f "${DEPLOYDIR}/optee/tee-${MACHINE}.srec" ]; then
        ln -sfr "${DEPLOYDIR}/optee/tee-${MACHINE}.srec" "${DEPLOYDIR}/tee-${MACHINE}.srec"
    fi
}
