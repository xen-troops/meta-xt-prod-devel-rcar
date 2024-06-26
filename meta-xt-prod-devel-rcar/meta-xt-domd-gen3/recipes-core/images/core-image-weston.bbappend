require common_install.inc

IMAGE_INSTALL:append = "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio wayland', ' virglrenderer libsdl2', '', d)} \
"
