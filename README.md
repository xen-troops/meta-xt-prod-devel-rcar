# meta-xt-prod-devel-rcar #

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
* Renesas Starter Kit Premiere 8GB (H3ULCB)
* Kingfisher with Starter Kit Premiere 8GB board
* AosBox with Starter Kit Premiere 8GB board
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
* Renesas Starter Kit Premiere (H3ULCB)
* Renesas Starter Kit Pro (M3ULCB)
* Audio back-end

# Building
## Requirements

1. Ubuntu 18.0+ or any other Linux distribution which is supported by Poky/OE
2. Development packages for Yocto. Refer to [Yocto
   manual](https://www.yoctoproject.org/docs/current/mega-manual/mega-manual.html#brief-build-system-packages).
3. You need `Moulin` installed in your PC. Recommended way is to
   install it for your user only: `pip3 install --user
   git+https://github.com/xen-troops/moulin`. Make sure that your
   `PATH` environment variable includes `${HOME}/.local/bin`.
4. Ninja build system: `sudo apt install ninja-build` on Ubuntu

## Fetching

You can fetch/clone this whole repository, but you actually need only
one file from it: `prod-devel-rcar.yaml`. During build `moulin` will
fetch this repository again into `yocto/` directory. So, to avoid
possible confusion, we recommend to download only `prod-devel-rcar.yaml`:

```
# curl -O https://raw.githubusercontent.com/xen-troops/meta-xt-prod-devel-rcar/master/prod-devel-rcar.yaml
```

## Building

Moulin is used to generate Ninja build file: `moulin
prod-devel-rcar.yaml`. This project provides a number
of additional options. You can use check them with
`--help-config` command line option:

```
# moulin prod-devel-rcar.yaml --help-config
usage: moulin prod-devel-rcar.yaml
       [--MACHINE {salvator-x-m3,salvator-xs-m3-2x4g,salvator-xs-h3,salvator-x-h3-4x2g}]
       [--ENABLE_ANDROID {no,yes}] [--ENABLE_DOMU {no,yes}]
       [--ENABLE_ZEPHYR {no,yes}] [--ENABLE_MM {no,yes}]
       [--ENABLE_AOS_VIS {no,yes}] [--PREBUILT_DDK {no,yes}]
       [--ANDROID_PREBUILT_DDK {no,yes}]

Config file description: Xen-Troops development setup for Renesas RCAR Gen3
hardware

optional arguments:
  --MACHINE {salvator-x-m3,salvator-xs-m3-2x4g,salvator-xs-h3,salvator-x-h3-4x2g}
                        RCAR Gen3-based device
  --ENABLE_ANDROID {no,yes}
                        Build Android as a guest VM
  --ENABLE_DOMU {no,yes}
                        Build generic Yocto-based DomU
  --ENABLE_ZEPHYR {no,yes}
                        Build Zephyr as guest domain
  --ENABLE_MM {no,yes}  Enable Multimedia support
  --ENABLE_AOS_VIS {no,yes}
                        Enable AOS VIS service
  --PREBUILT_DDK {no,yes}
                        Use pre-built GPU drivers
  --ANDROID_PREBUILT_DDK {no,yes}
                        Use pre-built GPU drivers for Android
```

To build for Salvator XS M3 8GB with DomU (generic yocto-based virtual
machine) use the following command line: `moulin prod-devel-rcar.yaml
--MACHINE salvator-xs-m3-2x4g --ENABLE_DOMU yes`.

Moulin will generate `build.ninja` file. After that - run `ninja` to
build the images. This will take some time and disk space, as it will
built 3 separate Yocto images. Depending on internet speed, this will
take 2-4 hours on Intel i7 with 32GB of RAM and 100 GB SSD.

To built for Salvator XS H3 8GB with Android VM use the following
command line: `moulin prod-devel-rcar.yaml --MACHINE
salvator-xs-h3-4x2g --ENABLE_ANDROID yes`.

This will require even more time and space, as Android is quite big.

## Building with prebuilts Android graphics

Prior to running moulin, you need to place android graphics prebuilts
archive `rcar-prebuilts-graphics-xt-doma.tar.gz` in the same directory
as yaml file.

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
