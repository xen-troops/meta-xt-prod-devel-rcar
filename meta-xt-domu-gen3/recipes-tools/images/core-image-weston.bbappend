IMAGE_INSTALL:append = " \
    pciutils \
    ${@bb.utils.contains('MACHINE_FEATURES', 'gsx', 'kmscube', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'gsx', 'glmark2', '', d)} \
    iperf3 \
    lisot \
    expect \
    ltrace \
    evtest \
"
