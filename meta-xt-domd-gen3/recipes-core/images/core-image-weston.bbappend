IMAGE_INSTALL:append = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' virglrenderer libsdl2', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' qemu-system-aarch64 qemu-keymaps', '', d)} \
    iperf3 \
"
