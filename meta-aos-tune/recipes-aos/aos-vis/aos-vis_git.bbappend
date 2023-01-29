FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = "\
    file://aos-vis.service \
    file://aos_vis.cfg \
"

# Use renesassimulatoradapter if nothing was specified at this point
AOS_VIS_PLUGINS ?= "\
    renesassimulatoradapter \
"

# storageadapter is required for proper work of any data provider
AOS_VIS_PLUGINS += "\
    storageadapter \
"

inherit systemd

SYSTEMD_SERVICE:${PN} = "aos-vis.service"

FILES:${PN} += " \
    ${sysconfdir}/aos/aos_vis.cfg \
    ${systemd_system_unitdir}/aos-vis.service \
    /var/aos/vis/data/*.pem \
"

RDEPENDS:${PN} += "\
    ${@bb.utils.contains('AOS_VIS_PLUGINS', 'telemetryemulatoradapter', 'telemetry-emulator', '', d)} \
"

do_prepare_adapters() {
    file="${S}/src/${GO_IMPORT}/plugins/plugins.go"

    echo 'package plugins' > ${file}
    echo 'import (' >> ${file}

    for plugin in ${AOS_VIS_PLUGINS}; do
        echo "\t_ \"${GO_IMPORT}/plugins/${plugin}\"" >> ${file}
    done

    echo ')' >> ${file}
}

python do_configure_adapters() {
    import json

    file_name = d.getVar("D")+"/etc/aos/aos_vis.cfg"

    with open(file_name) as f:
        data = json.load(f)

    for i, adapter_data in enumerate(data['Adapters']):
        if not adapter_data['Plugin'] in d.getVar("AOS_VIS_PLUGINS").split():
            del data['Adapters'][i]

    print(json.dumps(data, indent=4))

    with open(file_name, 'w') as f:
        json.dump(data, f, indent=4)
}

do_install:append() {
    if "${@bb.utils.contains('AOS_VIS_PLUGINS', 'telemetryemulatoradapter', 'true', 'false', d)}"; then

        if ! grep -q 'network-online.target telemetry-emulator.service' ${WORKDIR}/aos-vis.service ; then
            sed -i -e 's/network-online.target/network-online.target telemetry-emulator.service/g' ${WORKDIR}/aos-vis.service
        fi

        if ! grep -q 'ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service ; then
            sed -i -e '/ExecStart/i ExecStartPre=/bin/sleep 1' ${WORKDIR}/aos-vis.service
        fi
    fi

    install -d ${D}${sysconfdir}/aos
    install -m 0644 ${WORKDIR}/aos_vis.cfg ${D}${sysconfdir}/aos

    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/aos-vis.service ${D}${systemd_system_unitdir}/aos-vis.service

    install -d ${D}/var/aos/vis/crypt
    install -m 0644 ${S}/src/${GO_IMPORT}/data/*.pem ${D}/var/aos/vis/crypt
}

addtask configure_adapters after do_install before do_package
addtask prepare_adapters after do_unpack before do_compile
