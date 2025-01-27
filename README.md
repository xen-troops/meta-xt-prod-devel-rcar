# meta-xt-prod-devel-rcar #

# Table of contents

- [Overview](#overview)
- [Moulin project file](#moulin-project-file)
- [Building the project](#building-the-project)
  - [Requirements](#requirements)
  - [Fetching](#fetching)
  - [Building](#building)
  - [Build products](#build-products)
  - [Building with prebuilt graphics for DomD+DomU](#building-with-prebuilt-graphics-for-domddomu)
  - [Building with prebuilt graphics and Android guest](#building-with-prebuilt-graphics-and-android-guest)
    - [Creating SD card image](#creating-sd-card-image)
    - [Using rouge in standalone mode](#using-rouge-in-standalone-mode)
  - [Distro features](#distro-features)
  - [Virtio support](#virtio-support)

# Overview

This repository contains Renesas RCAR Gen3-specific Yocto layers for
Xen Troops distro and `moulin` project file to build it. Layers in this
repository provide final recipes to build meta-xt-prod-devel-rcar
distro. This distro is the main Xen Troops product, that we use to
develop and integrate new features

Those layers *may* be added and used manually, but they were written
with [Moulin](https://moulin.readthedocs.io/en/latest/) build system,
as Moulin-based project files provide correct entries in local.conf

# Moulin project file

Work is still in progress, but right now the following features are tested and working:

* Renesas Salvator-XS M3 with 8GB memory is supported
* Renesas Salvator-X H3 with 8GB memory is supported
* Renesas Starter Kit Premier 8GB (H3 ES3.0)
* Kingfisher with Starter Kit Premier 8GB board
* AosBox with Starter Kit Premier 8GB board
* GPU sharing between domains
* 3 domains are being built: Linux based Dom0, DomD and DomU
* Graphics back-end in DomD
* Networking in DomD and DomU
* Network (NFS) boot for DomD and DomU
* OP-TEE client in DomU
* Virtualized OP-TEE build
* ARM-TF that boots into EL2
* Multimedia (HW-assisted video decoding/encoding) support
* SD or eMMC boot
* Android VM support

Features that are present but not tested:

* Renesas Salvator-XS M3 with 4GB memory
* Renesas Salvator-XS H3 with 8GB memory
* Renesas Starter Kit Pro (M3ULCB)
* Audio back-end

# Building the project
## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto
   manual](https://docs.yoctoproject.org/ref-manual/system-requirements.html#required-packages-for-the-build-host).
3. You need `Moulin` installed in your PC. Recommended way is to
   install it for your user only: `pip3 install --user
   git+https://github.com/xen-troops/moulin`. Make sure that your
   `PATH` environment variable includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetching

You can clone this whole repository, or download it as an archive.
During the build few directories will be created and additional
dependencies will be fetched into them.
The build system will create build directory `yocto/` for yocto's
meta-layers, and `android/` directory depending on the build options.

## Building

Moulin is used to generate Ninja build file: `moulin
prod-devel-rcar.yaml`. This project provides a number
of additional options. You can use check them with
`--help-config` command line option:

```
# moulin prod-devel-rcar.yaml --help-config
usage: moulin prod-devel-rcar.yaml
       [--MACHINE {salvator-xs-m3-2x4g,salvator-xs-h3-4x2g,salvator-x-h3-4x2g,h3ulcb-4x2g,h3ulcb-4x2g-kf,h3ulcb-4x2g-ab}]
       [--ENABLE_ANDROID {no,yes}] [--ENABLE_DOMU {no,yes}]
       [--ENABLE_MM {no,yes}] [--GRAPHICS {binaries,sources}]

Config file description: Xen-Troops development setup for Renesas RCAR Gen3
hardware

optional arguments:
  --MACHINE {salvator-xs-m3-2x4g,salvator-xs-h3-4x2g,salvator-x-h3-4x2g,h3ulcb-4x2g,h3ulcb-4x2g-kf,h3ulcb-4x2g-ab}
                        RCAR Gen3-based device
  --ENABLE_ANDROID {no,yes}
                        Build Android as a guest VM
  --ENABLE_DOMU {no,yes}
                        Build generic Yocto-based DomU
  --ENABLE_MM {no,yes}  Enable Multimedia support
  --GRAPHICS {binaries,sources}]
                        Select how to use the GFX (3D hardware accelerator)
```

To build for StarterKit H3 8GB with DomU (generic yocto-based virtual
machine) use the following command line: `moulin prod-devel-rcar.yaml
--MACHINE h3ulcb-4x2g --ENABLE_DOMU yes`.

Moulin will generate `build.ninja` file. After that - run `ninja` to
build the images. This will take some time and disk space, as it will
built 3 separate Yocto images. Depending on internet speed, this will
take 2-4 hours on Intel i7 with 32GB of RAM and 100 GB SSD.

To build for StarterKit H3 8GB with Android VM use the following
command line: `moulin prod-devel-rcar.yaml --MACHINE
h3ulcb-4x2g --ENABLE_ANDROID yes`.

This will require even more time and space, as Android is quite big.

## Build products

During the build the following artifacts will be created.

After `moulin prod-devel-rcar.yaml`:
```
| build.ninja
```

After `ninja full.img`
```
| .stamps/
| .ninja_*
| yocto/            # Linux-based domains
  | build_dom?/
  | <fetched meta layers>/
| android_kernel/   # Android kernel
| android/          # Android
```

## Building with prebuilt graphics for DomD+DomU

Regular build, as described above, requires access to closed repo
with proprietary sources. But you may use prebuilt graphics binaries.
Please see instruction below.

1. You need to have prebuilt graphic binaries. Pay attention that you
can't use prebuilt binaries from Renesas for the non-virtio build because
those packages do not support virtualization. For the virtio build,
on the contrary, prebuilt binaries from Renesas must be used because of
GPU passthrough (native mode) instead of GPU sharing is in use there.
2. Put these binaries into `<directory_with_yaml>/../prebuilt_gsx/`.
By default prebuilt binaries are expected to be in the dedicated folder
on the same level as your folder with yaml. But this can be changed in
yaml file. Provide your directory in line
```
          XT_PREBUILT_GSX_DIR: "${TOPDIR}/../../../prebuilt_gsx"
```
Here we use the yocto variable `${TOPDIR}`. You may use yaml's variables
like `%{YOCTOS_WORK_DIR}`, but pay attention that `%` should be used when
referring to variables defined inside yaml. Also, you may provide an
absolute path on your build host.

During build each domain will look for its binaries inside the directory
with its name - "domd" or "domu". This name is specified by variable
`%{XT_DOM_NAME}` in yaml for each domain.

So, by default, you should have `domd` and `domu` folders with archives
under `prebuilt_gsx`. It looks like this:
```
prebuilt_gsx/
  domd/
    GSX_KM_H3.tar.bz2
    r8a77951_linux_gsx_binaries_gles.tar.bz2
  domu/
    GSX_KM_H3.tar.bz2
    r8a77951_linux_gsx_binaries_gles.tar.bz2
<your work directory with prod-devel-rcar.yaml and build.ninja generated by moulin>
  prod-devel-rcar.yaml
  build.ninja
  <... other build related files and directories ...>
```

3. Use `--GRAPHICS binaries` command line option for moulin.

Run build as usual with `ninja`.

## Building with prebuilt graphics and Android guest

### Preparation

You need to prepare prebuilt graphic binaries before building. Since Android
guest is supported only in the virtio-based build, we use prebuilt graphic
binaries without virtualization.

1. Create a folder for the prebuilt binaries
`<directory_with_yaml>/../prebuilt_gsx/domd/`. You may use any other folder,
but it should be specified inside the `prod-devel-rcar-virtio.yaml` variable
`XT_PREBUILT_GSX_DIR`.

2. Download the "R-Car Gen3 Evaluation Software Package for Linux for Yocto v5.9.0"
from Renesas site:
https://www.renesas.com/us/en/application/automotive/r-car-h3-m3-h2-m2-e2-documents-software
(registration may be required).

Two files are required:
- [R-Car_Gen3_Series_Evaluation_Software_Package_for_Linux-20220121.zip](https://www.renesas.com/en/document/swo/r-cargen3seriesevaluationsoftwarepackageforlinux-20220121?r=1245356)
- [R-Car_Gen3_Series_Evaluation_Software_Package_of_Linux_Drivers-20220121.zip](https://www.renesas.com/en/document/swo/r-cargen3seriesevaluationsoftwarepackageoflinuxdrivers-20220121?r=1245356)

3. Extract the required drivers from the downloaded pack of archives.

- From `R-Car_Gen3_Series_Evaluation_Software_Package_of_Linux_Drivers-20220121.zip`
get `RCH3G001L5101ZDO_4_2_1.zip`. From that last archive,
get `GSX_KM_H3.tar.bz2`, and put it into the folder `prebuilt_gsx/domd/`
created in step 1.

- From `R-Car_Gen3_Series_Evaluation_Software_Package_for_Linux-20220121.zip`
get `INFRTM8RC7795ZG300Q10JPL3E_4_2_1.zip`. From that last archive, get
`INF_r8a77951_linux_gsx_binaries_gles.tar.bz2`.

Rename `INF_r8a77951_linux_gsx_binaries_gles.tar.bz2` to
`r8a77951_linux_gsx_binaries_gles.tar.bz2`, and put it into the folder
`prebuilt_gsx/domd/`  created in step 1.

As the result of these operations, you should have `prebuilt_gsx/domd/` folder
with the following files:
```
prebuilt_gsx/
  domd/
    GSX_KM_H3.tar.bz2
    r8a77951_linux_gsx_binaries_gles.tar.bz2
<your work directory with prod-devel-rcar-virtio.yaml>
  prod-devel-rcar-virtio.yaml
  <... other build related files and directories ...>
```

### Build

Use `--GRAPHICS binaries` command line option for moulin:
```
moulin prod-evel-rcar-virtio.yaml --MACHINE h3ulcb-4x2g --ENABLE_ANDROID yes --GRAPHICS binaries
ninja full.img
```

## Creating SD card image

Image file can be created with `rouge` tool. This is a companion
application for `moulin`.

It can be invoked either as a standalone tool, or via Ninja.

### Creating image(s) via Ninja

Newer versions of `moulin` (>= 0.5) will generate two additional Ninja
targets:

 - `image-full`
 - `image-android_only` (if building with `--ENABLE_ANDROID=yes`)

Thus, you can just run `ninja image-full` or `ninja full.img` which
will generate the `full.img` in your build directory.

Then you can use `dd` to write this image to your SD card. Don't
forget `conv=sparse` option for `dd` to speed up writing.

### Using `rouge` in standalone mode

In this mode you can write image right to SD card. But it requires
additional options.

In standalone mode`rouge` accepts the same parameters like
`--MACHINE`, `--ENABLE_ANDROID`, `--ENABLE_DOMU` as `moulin` do.

This XT product provides two images: `full` and `android_only`. Latter
is available only when `--ENABLE_ANDROID=yes`.

You can prepare image by running

```
# rouge prod-devel-rcar.yaml --ENABLE_DOMU=yes --ENABLE_ANDROID=no -i full
```

This will create file `full.img` in your current directory.

Also you can write image directly to a SD card by running

```
# sudo rouge prod-devel-rcar.yaml --ENABLE_DOMU=yes --ENABLE_ANDROID=no -i full -so /dev/sdX
```

**BE SURE TO PROVIDE CORRECT DEVICE NAME**. `rouge` have no
interactive prompts and will overwrite your device right away.
**ALL DATA WILL BE LOST**.

If you want to generate only Android sub-image use `-i android_only`
option.

For more information about `rouge` check its
[manual](https://moulin.readthedocs.io/en/latest/rouge.html).

# Distro features

This repository introduces the following Yocto **DISTRO_FEATURES**. They are used, or not used, depending on the moulin build parameters.

|Distro feature|Comment|Typical use-case|
|---|---|---|
|displbe|Specifies whether to build and to install [this](https://github.com/xen-troops/displ_be) implementation as a 'displbe' systemd service.|Disabled in virtio build|
|sndbe|Specifies whether to build and to install [this](https://github.com/xen-troops/snd_be) implementation as a 'sndbe' systemd service.|Disabled in virtio build|
|enable_virtio|Specifies, whether we are building system, in which DomD should share devices with the guest domain over the virtio specification.|Enabled in virtio build|

# Virtio support
To build the product with the support of virtio, use the [prod-devel-rcar-virtio.yaml](https://github.com/xen-troops/meta-xt-prod-devel-rcar/blob/master/prod-devel-rcar-virtio.yaml).

Building with this moulin configuration will lead to the following high-level changes within the system:

- Disabled displbe.service in the driver domain
- Disabled sndbe.service in the driver domain
- Disabled display-manager.service in the driver domain
- Extended doma(u).service in the control domain. The extension is done through the systemd drop-in mechanism. For more details refer to the meta-xt-common->meta-xt-control-domain-virtio. Search for doma(u).bbappend
- Modified Xen configuration for guest domains
- Changed memory amount assigned to the driver and the guest domains
- Changed set of the installed packages, e.g. qemu

To find the majority of those differences search for the:

- "enable_virtio" keyword,
- meta-xt-...-virtio layers,

in [this](https://github.com/xen-troops/meta-xt-prod-devel-rcar) and [meta-xt-common](https://github.com/xen-troops/meta-xt-common) repositories.
