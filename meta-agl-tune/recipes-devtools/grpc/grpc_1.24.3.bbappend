
do_install:append() {
    # This is the fix for the fix of 'Bug-AGL SPEC-4405'.
    # It is needed due to change of version of c-ares in OE.
    # See 9d336d94a35b124e59c83b0ea08f93f1a51bb165 in meta-agl-demo
    sed -i "s/^set(PACKAGE_VERSION \"[0-9.]*\")$/set(PACKAGE_VERSION \"${PV}\")/" ${D}/${libdir}/cmake/${BPN}/gRPCConfigVersion.cmake
}

