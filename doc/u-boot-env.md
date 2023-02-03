# General note

All commands described below are available as 'default environment' for u-boot built after 2022 February 17.

If you see that required commands are corrupted or missing, you can reset the environment in the u-boot using
```
env default -a
```
Check that required commands are available, using `print` command.

And store the environment by `saveenv` command.


# Boot storage device setting

Boot device is selected by setting 'bootcmd' variable. E.g. `setenv bootcmd run bootcmd_emmc`. Other available options are listed below.

## Common settings, recommended for any boot device
```
setenv bootargs
setenv ethact ravb
setenv ipaddr 192.168.1.10
setenv serverip 192.168.1.100
setenv initrd_high 0xffffffffffffffff
```

If you need to set MAC, use variable `ethaddr` and MAC address provided on sticker on ethernet connector on board.
Use following format:
```
setenv ethaddr 12:34:56:78:9A:BC
```

## TFTP boot
```
setenv tftp_xen_load tftp 0x48080000 xen
setenv tftp_dtb_load 'tftp 0x48000000 xen.dtb; fdt addr 0x48000000; fdt resize; fdt mknode / boot_dev; fdt set /boot_dev device nfs; fdt set /boot_dev my_ip ${ipaddr}; fdt set /boot_dev nfs_server_ip ${serverip}; fdt set /boot_dev nfs_dir "/srv/domd-YOUR_BOARD";'
setenv tftp_kernel_load tftp 0x8a000000 Image
setenv tftp_xenpolicy_load tftp 0x8c000000 xenpolicy
setenv tftp_initramfs_load tftp 0x84000000 uInitramfs
setenv bootcmd_tftp 'run tftp_xen_load; run tftp_dtb_load; run tftp_kernel_load; run tftp_xenpolicy_load; run tftp_initramfs_load; bootm 0x48080000 0x84000000 0x48000000'
setenv bootcmd run bootcmd_tftp
```
### NFS related properties in a device tree file
#### my_ip
IP address of this board
#### nfs_server_ip
IP address of a connected machine where NFS server is started
#### nfs_dir
Exported path of the root FS.

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

## Bootloaders from eMMC
In case of boot SoC from the eMMC boot partition 1 (50MHz x8 bus width mode) instead of Serial Flash,
we have an ability to flash firmware and loaders using U-Boot. Pay attention that images must be in raw binary format.

Partitions and offsets were retrieved from
https://github.com/renesas-rcar/flash_writer/blob/rcar_gen3/docs/application-note.md#348-write-to-the-s-record-format-images-to-the-emmc

#### NOTE 1
To select source of loaders, use on-board switches: SW10 on Salvator-X/XS and SW6 on StarterKit.

For Salvator boards set `SW10[5..8]` to `[OFF OFF ON OFF]` for eMMC and inverted values `[ON ON OFF ON]` for HyperFlash.

For StarterKit set `SW6[4]` to `[OFF]` for bootloaders on eMMC, and `[ON]` for HyperFlash.

To make sure that loaders are loaded from expected place, look for the line `NOTICE:  BL2: Boot device is ` during start of the board.


#### NOTE 2
To activate the possibility of booting SoC from the eMMC, the content of the next EXT_CSD registers should be changed.
This procedure should be done only once.
```
[179:179]  PARTITION_CONFIG                           0x08
[177:177]  BOOT_BUS_CONDITIONS                        0x0A
```
Boot `Flash Writer` according to instruction https://elinux.org/R-Car/Boards/H3SK#Tips.

Use EM_SECSD command to change 177(0xB1) and 179(0xB3) registers. E.g.:
```
>EM_SECSD
  Please Input EXT_CSD Index(H'00 - H'1FF) :B3
  EXT_CSD[B3] = 0x00
  Please Input Value(H'00 - H'FF) :8
  EXT_CSD[B3] = 0x08
```

Use following commands to flash loaders to eMMC:
```
setenv flash_bootparam_sa0 'tftp 0x48000000 bootparam_sa0.bin; mmc dev 1 1; mmc write 0x48000000 0x0 0x1E;'
setenv flash_bl2 'tftp 0x48000000 bl2.bin; mmc dev 1 1; mmc write 0x48000000 0x1E 0x162;'
setenv flash_cert_header_sa6 'tftp 0x48000000 cert_header_sa6_emmc.bin; mmc dev 1 1; mmc write 0x48000000 0x180 0x80;'
setenv flash_bl31 'tftp 0x48000000 bl31.bin; mmc dev 1 1; mmc write 0x48000000 0x200 0xE00;'
setenv flash_tee 'tftp 0x48000000 tee.bin; mmc dev 1 1; mmc write 0x48000000 0x1000 0x600;'
setenv flash_u_boot 'tftp 0x48000000 u-boot.bin; mmc dev 1 2; mmc write 0x48000000 0x0 0x800;'
setenv flash_z_loaders 'run flash_bootparam_sa0; run flash_bl2; run flash_cert_header_sa6; run flash_bl31; run flash_tee; run flash_u_boot;'
```

To flash loaders to HyperFlash (available for Kingfisher only):
```
setenv flash_hf_bootparam_sa0 'tftp 0x48000000 bootparam_sa0.bin; erase 0x08000000 +0x${filesize}; cp.b 0x48000000 0x08000000 0x${filesize};'
setenv flash_hf_bl2 'tftp 0x48000000 bl2.bin; erase 0x08040000 +0x${filesize}; cp.b 0x48000000 0x08040000 0x${filesize};'
setenv flash_hf_cert_header_sa6 'tftp 0x48000000 cert_header_sa6.bin; erase 0x08180000 +0x${filesize}; cp.b 0x48000000 0x08180000 0x${filesize};'
setenv flash_hf_bl31 'tftp 0x48000000 bl31.bin; erase 0x081C0000 +0x${filesize}; cp.b 0x48000000 0x081C0000 0x${filesize};'
setenv flash_hf_tee 'tftp 0x48000000 tee.bin; erase 0x08200000 +0x${filesize}; cp.b 0x48000000 0x08200000 0x${filesize};'
setenv flash_hf_u_boot 'tftp 0x48000000 u-boot.bin; erase 0x08640000 +0x${filesize}; cp.b 0x48000000 0x08640000 0x${filesize};'
setenv flash_hf_loaders 'run flash_hf_bootparam_sa0; run flash_hf_bl2; run flash_hf_cert_header_sa6; run flash_hf_bl31; run flash_hf_tee; run flash_hf_u_boot;'
```

Save changes
```
saveenv
```
