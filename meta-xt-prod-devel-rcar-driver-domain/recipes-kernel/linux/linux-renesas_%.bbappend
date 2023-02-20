FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://defconfig \
    file://0001-OF-DT-Overlay-configfs-interface-v7.patch \
    file://0002-of-overlay-kobjectify-overlay-objects.patch \
    file://0003-of-overlay-global-sysfs-enable-attribute.patch \
    file://0004-Documentation-ABI-overlays-global-attributes.patch \
    file://0005-Documentation-document-of_overlay_disable-parameter.patch \
    file://0006-of-overlay-add-per-overlay-sysfs-attributes.patch \
    file://0007-Documentation-ABI-overlays-per-overlay-docs.patch \
    file://0008-of-rename-_node_sysfs-to-_node_post.patch \
"

