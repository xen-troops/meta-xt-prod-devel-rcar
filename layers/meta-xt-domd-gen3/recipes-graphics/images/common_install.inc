IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'sndbe', 'sndbe', '', d)} \
"
