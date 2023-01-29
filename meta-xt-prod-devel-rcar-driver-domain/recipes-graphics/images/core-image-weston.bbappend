IMAGE_INSTALL:append = " \
    sndbe \
    ${@bb.utils.contains('DISTRO_FEATURES', 'pvcamera', 'camerabe', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'vis', 'aos-vis', '', d)} \
"

# We add 500 MB of free space for media content.
# Variable specifies space in KBytes.
# Also see IMAGE_OVERHEAD_FACTOR as another way to increase free space.
IMAGE_ROOTFS_EXTRA_SPACE = "512000"
