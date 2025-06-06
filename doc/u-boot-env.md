# The u-boot environment for the meta-xt-prod-devel-rcar

The correct boot of the product requires the proper setting of the u-boot
environment.
This document describes settings for different boot devices. You have to set
the common part of the environment and the part specific to your boot device.

## Common settings for any boot device
```
env delete bootargs
env delete bootm_size
setenv initrd_high 0xffffffffffffffff
```
You have to set Ethernet-related variables. Pay attention that `ethaddr` can be
set only once. If you need to change it, the u-boot environment has to be reset
to the default by `env default -a` and all variables need to be provided again.

Set the MAC address provided on the sticker on the Ethernet connector on the
board, the IP address of the board, and the server
```
setenv ethaddr __:__:__:__:__:__
setenv ipaddr __.__.__.__
setenv serverip __.__.__.__
```

## TFTP boot
```
setenv tftp_xen_load tftp 0x48080000 xen
setenv tftp_dtb_load 'tftp 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device nfs; fdt set /boot_dev my_ip ${ipaddr}; fdt set /boot_dev nfs_server_ip ${serverip}; fdt set /boot_dev nfs_dir "/srv/nfs/domd"; fdt set /boot_dev domu_nfs_dir "/srv/nfs/domu"'
setenv tftp_kernel_load tftp 0x8a000000 Image
setenv tftp_xenpolicy_load tftp 0x8c000000 xenpolicy
setenv tftp_initramfs_load tftp 0x84000000 uInitramfs
setenv bootcmd_tftp 'run tftp_xen_load; run tftp_dtb_load; run tftp_kernel_load; run tftp_xenpolicy_load; run tftp_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd run bootcmd_tftp
```
### NFS related properties in a device tree file
Values for these properties have to be set according to your work environment.
#### my_ip
IP address of this board
#### nfs_server_ip
IP address of a connected machine where NFS server is started
#### nfs_dir
Exported path of the root FS of DomD
### domu_nfs_dir
Exported path of the root FS of DomU

## eMMC boot
```
setenv emmc_xen_load ext2load mmc 1:1 0x48080000 xen
setenv emmc_dtb_load 'ext2load mmc 1:1 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk0'
setenv emmc_kernel_load ext2load mmc 1:1 0x8a000000 Image
setenv emmc_xenpolicy_load ext2load mmc 1:1 0x8c000000 xenpolicy
setenv emmc_initramfs_load ext2load mmc 1:1 0x84000000 uInitramfs
setenv bootcmd_emmc 'run emmc_xen_load; run emmc_dtb_load; run emmc_kernel_load; run emmc_xenpolicy_load; run emmc_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd run bootcmd_emmc
```

## SD0 card boot
```
setenv sd0_xen_load ext2load mmc 0:1 0x48080000 xen
setenv sd0_dtb_load 'ext2load mmc 0:1 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk1'
setenv sd0_kernel_load ext2load mmc 0:1 0x8a000000 Image
setenv sd0_xenpolicy_load ext2load mmc 0:1 0x8c000000 xenpolicy
setenv sd0_initramfs_load ext2load mmc 0:1 0x84000000 uInitramfs
setenv bootcmd_sd0 'run sd0_xen_load; run sd0_dtb_load; run sd0_kernel_load; run sd0_xenpolicy_load; run sd0_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd run bootcmd_sd0
```

## SD3 card boot (Salvator-X, -XS only)
```
setenv sd3_xen_load ext2load mmc 2:1 0x48080000 xen
setenv sd3_dtb_load 'ext2load mmc 2:1 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device mmcblk2'
setenv sd3_kernel_load ext2load mmc 2:1 0x8a000000 Image
setenv sd3_xenpolicy_load ext2load mmc 2:1 0x8c000000 xenpolicy
setenv sd3_initramfs_load ext2load mmc 2:1 0x84000000 uInitramfs
setenv bootcmd_sd3 'run sd3_xen_load; run sd3_dtb_load; run sd3_kernel_load; run sd3_xenpolicy_load; run sd3_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd run bootcmd_sd3
```
