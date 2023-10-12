PACKAGECONFIG:append = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' gtk+ vhost', '', d)}"
PACKAGECONFIG:remove = "${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' kvm', '', d)}"
