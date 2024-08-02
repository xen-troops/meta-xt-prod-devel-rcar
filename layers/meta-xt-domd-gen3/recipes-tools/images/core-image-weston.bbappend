require common_install.inc

IMAGE_INSTALL:append = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'gsx', 'kmscube', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'gsx', 'glmark2', '', d)} \
"
