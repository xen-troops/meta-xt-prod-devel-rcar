DESCRIPTION = "Linux socket test tool"
SECTION = "extras"
LICENSE = "Apache-2.0"
PR = "r0"

S = "${WORKDIR}/git"

SRC_URI = " \
    git://github.com/xen-troops/lisot.git;protocol=https;branch=main \
"

LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRCREV = "ea3da7cd2fd18059701ea67293d96f797f9ac39b"

do_compile() {
    oe_runmake SYSROOT=${RECIPE_SYSROOT}
}

do_install() {
    oe_runmake install DESTDIR=${D}
}
