# meta-xt-prod-devel-rcar #

# Table of contents

- [Overview](#overview)
- [Prerequirements](#prerequirements)
- [Build the product](#build-the-product)
- [Flash the board](#flash-the-board)

# Overview

This repository contains Renesas RCAR Gen3-specific Yocto layers for Xen Troops
distro and [moulin](https://github.com/xen-troops/moulin) project file to
build it. Layers in this repository provide final recipes to build the
meta-xt-prod-devel-rcar distro.

Supported boards:
- Renesas Starter Kit Premier 8GB (H3 ES3.0)
- Renesas Starter Kit Premier 8GB with Kingfisher (H3 ES3.0)
- Renesas Salvator-XS M3 with 8GB
- Renesas Salvator-X H3 with 8GB
- AosBox with Starter Kit Premier 8GB board

The following features are tested:
- GPU sharing between domains
- Linux guest domain
- Android guest domain
- Hardware 3D graphics in multiple domains
- Networking in Linux and Android
- Network (NFS) boot for Linux domains
- OP-TEE client in the Linux guest
- Virtualized OP-TEE
- ARM-TF that boots into EL2
- Multimedia (HW-assisted video decoding/encoding) support
- SD or eMMC boot
- Audio playback and recording


To simplify the document, this quicktart guide assumes that the build is
performed on the x86 Ubuntu host, inside the Docker container.


## Prerequirements

### hardware
It is strogly recommended to have an SSD drive and 32GB of RAM due to significant
usage of the resources during the build.
At least 150GB of free space is expected for the Linux guest, and 500GB for
the Android guest.

### git
Install `git` and create `~/.gitconfig` file
```
sudo apt install git
git config --global user.name "your name"
git config --global user.email "your e-mail"
```
The `~/.gitconfig` is required due to limitations of the existing `Dockerfile`.

### docker
Install Docker and add yourself to the `docker` group to run it without `sudo`
```
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
```
Log out and log in again to properly apply the new group.
Follow https://docs.docker.com/engine/install/linux-postinstall/ in case of any
issue.

### prebuilt graphics binaries
This product requires proprietary prebuilt binaries for graphics.
Depending of the backends used (PV or virtio) you need different packages.

If you are going to use virtio-based backends (prod-devel-rcar-virtio.yaml), you
have to download Kirkstone-based packages
- R-Car_Gen3_Series_Evaluation_Software_Package_for_Linux-20220121
- R-Car_Gen3_Series_Evaluation_Software_Package_of_Linux_Drivers-20220121
from https://www.renesas.com/en/products/automotive-products/automotive-system-chips-socs/r-car-h3-m3-documents-software.
Find and extract `GSX_KM_H3.tar.bz2` and
`INF_r8a77951_linux_gsx_binaries_gles.tar.bz2`.
Rename INF_r8a77951_linux_gsx_binaries_gles.tar.bz2.
```
mv INF_r8a77951_linux_gsx_binaries_gles.tar.bz2 r8a77951_linux_gsx_binaries_gles.tar.bz2
```
and put both of them like this
```
prebuilt_gsx/
  domd/
    GSX_KM_H3.tar.bz2
    r8a77951_linux_gsx_binaries_gles.tar.bz2
<your work directory with prod-devel-rcar-virtio.yaml>
  prod-devel-rcar-virtio.yaml
  <... other build-related files and directories ...>
```

If you plan to use PV backends (prod-devel-rcar.yaml), please contact Renesas
to obtain graphics with virtualization support. Please note that these are not
the same package that can be downloaded from the Renesas website.

### TFTP server
Install TFTP server. It is used for flashing IPLs and the image.
```
sudo apt-get install tftp tftpd-hpa
```

### flashing tools
Get `rcar_flash`.

```
https://github.com/xen-troops/rcar_flash.git
```

You need to install a few Python3 packages for this tool, and set proper
access rights
```
sudo apt install python3-serial python3-ftdi
sudo usermod -aG dialout $USER
```
See https://github.com/xen-troops/rcar_flash/blob/main/README.md#initial-setup
for details.


## Build the product
Get the sources
```
git clone https://github.com/xen-troops/meta-xt-prod-devel-rcar.git
cd meta-xt-prod-devel-rcar
export WORK_DIR=`pwd`
```

Create the build container
```
docker build . -f ./doc/Dockerfile --build-arg "USER_ID=$(id -u)" --build-arg "USER_GID=$(id -g)" -t u20
```
Start the build container
```
./doc/run_docker.sh -w . -d u20
```
Create the product configuration, selecting PV/virtio backends, machine, and
guests depending on your requirements.

Here are some examples. Use `moulin prod-devel-rcar-virtio.yaml --help-config`
to see other available build options.

Starterkit Premier H3 8GB (h3ulcb-4x2g), Linux guest
```
moulin prod-devel-rcar-virtio.yaml --ENABLE_DOMU yes
```
Starterkit Premier H3 8GB with Kingfisher (h3ulcb-4x2g-kf), Linux guest
```
moulin prod-devel-rcar-virtio.yaml --MACHINE h3ulcb-4x2g-kf --ENABLE_DOMU yes
```
Starterkit Premier H3 8GB with Kingfisher (h3ulcb-4x2g-kf), Android guest, use
multimedia codecs
```
moulin prod-devel-rcar-virtio.yaml --MACHINE h3ulcb-4x2g-kf --ENABLE_ANDROID yes --ENABLE_MM yes
```

Start the build
```
ninja full.img.gz
```

Building takes up to 5-8 hours, or more, on the regular Intel i7 CPU, depending
on your host's hardware and internet bandwidth.

After the successful building, you may quit the container.


## Flash the board

The flashing is performed on the host (not in the container).

For the simplicity of this guide, we assume that only one board is connected
to the host, with `/dev/ttyUSB0` as the serial device used as the console.
The TFTP server on the host has `/srv/tftp` as TFTP root directory.

Examples below are provided for the StarterKit Premier (h3ulcb-4x2g) with the
product running from the eMMC. For other cases, please see manuals for
corresponding tools and boards.

### loaders
We use [rcar_flash](https://github.com/xen-troops/rcar_flash) for flashing
loaders.

All of the loaders (IPLs - Initial Program Loaders) are located in the
`${WORK_DIR}/yocto/build-domd/tmp/deploy/images/h3ulcb/` except one file, due to
the known to us issue in the yocto recipes.
You need to copy it manually
```
cp ${WORK_DIR}/yocto/build-domd/tmp/deploy/images/h3ulcb/optee/tee-h3ulcb.srec ${WORK_DIR}/yocto/build-domd/tmp/deploy/images/h3ulcb/
```

Flash the IPLs with the following command
```
./rcar_flash.py flash -c -f -b h3ulcb_4x2 -s /dev/ttyUSB0 -p ${WORK_DIR}/yocto/build-domd/tmp/deploy/images/h3ulcb/firmware all
```

### u-boot env
Connect to the board using `picocom` or another terminal. Reboot the board and
press any key to stop u-boot.

Set the MAC according to the sticker on the Ethernet connector. Set the board
IP and server IP.
```
setenv ethaddr __:__:__:__:__:__
setenv ipaddr __.__.__.__
setenv serverip __.__.__.__
```

Set commands required for the proper work of the u-boot.

For the h3ulcb-4x2g with the product running on the eMMC
```
env delete bootargs
env delete bootm_size

setenv bootcmd_emmc=run emmc_xen_load; run emmc_dtb_load; run emmc_kernel_load; run emmc_xenpolicy_load; run emmc_initramfs_load; bootm 0x48080000 0x84000000 0x48000000
setenv emmc_dtb_load=ext2load mmc 1:1 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk0
setenv emmc_initramfs_load=ext2load mmc 1:1 0x84000000 uInitramfs
setenv emmc_kernel_load=ext2load mmc 1:1 0x8a000000 Image
setenv emmc_xen_load=ext2load mmc 1:1 0x48080000 xen
setenv emmc_xenpolicy_load=ext2load mmc 1:1 0x8c000000 xenpolicy
setenv bootcmd run bootcmd_emmc
saveenv
```

In case of the usage of TFTP/NFS or SD cards, please see [doc/u-boot-env.md].

### image
Put previously built `full.img.gz` to the root of the TFTP server
```
cp ${WORK_DIR}/full.img.gz /srv/tftp
```
In the u-boot console, type the following
```
tftp 0x500000000 full.img.gz; gzwrite mmc 1 0x500000000 ${filesize} 400000 0
```

After a few minutes, start the image by typing in the u-boot console
```
boot
```

The board will start loading Xen with all domains from the eMMC.
