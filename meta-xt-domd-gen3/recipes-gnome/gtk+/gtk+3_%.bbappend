# Avoid installation of the redundant 'adwaita-icon-theme' package.
# It is causing build of the rust, which we want to avoid, as it takes a lot of time.
RRECOMMENDS:${PN}:remove = " adwaita-icon-theme-symbolic"
RRECOMMENDS:${PN}:libc-glibc:remove = " adwaita-icon-theme-symbolic"
