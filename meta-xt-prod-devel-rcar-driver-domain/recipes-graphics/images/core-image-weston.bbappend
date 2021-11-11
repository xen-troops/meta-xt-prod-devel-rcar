IMAGE_INSTALL_append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'vis', 'aos-vis', '', d)} \
"
