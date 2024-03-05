IMAGE_INSTALL:append = " \
    pciutils \
    ${@bb.utils.contains('MACHINE_FEATURES', 'gsx', 'kmscube', '', d)} \
    iperf3 \
    lisot \
"
