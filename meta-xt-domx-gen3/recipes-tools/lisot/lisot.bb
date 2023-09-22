DESCRIPTION = "Linux socket test tool"
SECTION = "extras"
LICENSE = "MIT"
PR = "r0"

S = "${WORKDIR}/git"

SRC_URI = " \
    git://github.com/dterletskiy/lisot.git;protocol=https;branch=main \
"

LIC_FILES_CHKSUM = "file://LICENSE;md5=70f43a6798ce05aa97a93b0392832ee9"

SRCREV = "${AUTOREV}"

do_compile() {
    oe_runmake SYSROOT=${RECIPE_SYSROOT}
}

do_install() {
    oe_runmake install DESTDIR=${D}
}
