IMAGE_INSTALL_append = " \
    sndbe \
    ${@bb.utils.contains('DISTRO_FEATURES', 'vis', 'aos-vis', '', d)} \
"
