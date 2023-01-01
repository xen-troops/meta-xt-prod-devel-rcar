FILESEXTRAPATHS:prepend:rcar-gen3 := "${THISDIR}/${PN}:"

SRC_URI:append:rcar-gen3 = " \
	file://kingfisher_output.cfg \
	file://ebisu_output.cfg \
	file://salvator-x_output.cfg \
"

WESTON_FRAGMENTS:append:ulcb = " kingfisher_output"
WESTON_FRAGMENTS:append:ebisu = " ebisu_output"
WESTON_FRAGMENTS:append:salvator-x = " salvator-x_output"

do_configure:append:rcar-gen3() {
    echo repaint-window=8 >> ${WORKDIR}/core.cfg
}
