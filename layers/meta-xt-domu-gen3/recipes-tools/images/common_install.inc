IMAGE_INSTALL:append = " \
    pciutils \
    iperf3 \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', 'lisot', '', d)} \
    expect \
    ltrace \
    evtest \
"
