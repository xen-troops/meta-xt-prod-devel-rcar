This layer contains files that were:
 - copied as-is or adopted from AGL layer meta-agl/meta-agl-bsp/meta-rcar-gen3;
 - developed by EPAM.

We can't use meta-agl-bsp due to lots of conflicts in the handling prebuilt
binaries and duplication of functionality with our layers.
So we bbmask'ed meta-agl-bsp/meta-rcar-gen3 and manually cherry-picked some
required files.

Files under some directories do not have a proper git log, as they were copied
from the external repo. We've included the authors of the files below.

- recipes-graphics/wayland
  Ronan Le Martret <ronan.lemartret@iot.bzh>
  Scott Murray <scott.murray@konsulko.com>
  Jan-Simon Moeller <jsmoeller@linuxfoundation.org>
  Duy Dang <duy.dang.yw@renesas.com>
  Pierre Marzin <pierre.marzin@iot.bzh>
  Harunobu Kurokawa <harunobu.kurokawa.dn@renesas.com>
  Tom Rini <trini@konsulko.com>
  Yannick Gicquel <yannick.gicquel@iot.bzh>
Look into the complete `git log` for details
https://gerrit.automotivelinux.org/gerrit/gitweb?p=AGL/meta-agl.git;a=history;f=meta-agl-bsp/meta-rcar-gen3/recipes-graphics/wayland;hb=HEAD

- recipes-kernel/kernel-module-gles
  Ronan Le Martret <ronan.lemartret@iot.bzh>
  Scott Murray <scott.murray@konsulko.com>
  Jan-Simon Moeller <jsmoeller@linuxfoundation.org>
  Yannick Gicquel <yannick.gicquel@iot.bzh>
Look into the complete `git log` for details
https://gerrit.automotivelinux.org/gerrit/gitweb?p=AGL/meta-agl.git;a=history;f=meta-agl-bsp/meta-rcar-gen3/recipes-kernel/kernel-module-gles;hb=HEAD

- recipes-kernel/linux
  Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>

