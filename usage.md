# Usage of the product

## Table of content

- [What you have to have](#what-you-have-to-have)
- [Setup connections and software](#setup-connections-and-software)
  - Serial
  - Ethernet
  - Flashing script
  - Python3 packages
- [Flashing loaders](#flashing-loaders)
- [Flashing the image of the product](#flashing-the-image-of-the-product)
- [Run on SD-card](#run-on-sd-card)
- [Run on eMMC](#run-on-emmc)
- [What to do on the board](#what-to-do-on-the-board)


## What you have to have

Product files:
- `full.img` - file with product's image.
- `ipl-MACHINE.tar.bz2` - initial program loaders, OP-TEE OS and u-boot

Where MACHINE is the name of your board (e.g., h3lucb-4x2g, h3ulcb-4x2g-kf, etc).

Hardware:
- the board itself with power suply
- USB-A to mini-USB cable
- ethernet cable
- SD-card if you plan to run the product from the SD-card

Software for your PC:
- rcar_flash script
- python3
- python packages (see [Python3 packages](#python3-packages) below)
- unzip tool


## Setup connections and software

### Serial
To flash IPL (loaders) you need to have serial connection from PC to the board.
Connect USB cable from your PC to 'Debug Serial' port on the board.

To locate required port see photo on the page for your board:
- Starter Kit Premier (H3SK) - https://elinux.org/R-Car/Boards/H3SK
- Starter Kit Premier with Kingfisher - same as for "Starter Kit Premier (H3SK)"
- AosBox (CCPF-SK) - https://elinux.org/R-Car/Boards/CCPF-SK
- Salvator-X, -XS with H3 - https://xen-troops.github.io/documentation/Connect-cables-to-Salvator-X,-XS

### Ethernet
To flash the image file you need to have TFTP server on your PC and the board have to be connectged to the same network as your PC.
You may connect the board to the network switch/router or to the second ethernet adapter on your PC.

### Flashing script
The rcar_flash script is required to flash the loaders. It is located at https://github.com/xen-troops/rcar_flash.
Please download and unpack the zip-archive
```
wget https://github.com/xen-troops/rcar_flash/archive/refs/heads/main.zip
unzip main.zip
```
Required files will be located in the `rcar_flash-main` folder.

### Python3 packages
You need to install few packages for python3 as root.
This is required due to need for special access to the USB, to set the board into download mode.
```
sudo pip3 install --user pyserial pyftdi
```


## Flashing loaders

Unpack loaders `ipl-{MACHINE}.tar.bz2` to some folder.

General way to run script is
```
sudo ./rcar_flash.py flash -b <board-name> -c -f -p <path-to-loader-files> all
```

The `sudo` command is required due to option `-c` that is used to control on-board CPLD to switch the board into download mode.

In case of any issues, please see script's documentation at https://github.com/xen-troops/rcar_flash.


## Flashing the image of the product
The product may run from SD-card or from eMMC.

Let's assume that serial connection to the board is on /dev/ttyUSB0.

### Run on SD-card
Write full.img to SD-card on your PC.
Use `dd`
```
sudo dd if=./full.img of="<path_to_your_sd_card_like_/dev/sdX>" bs=1M status=progress
```
or `bmap`
```
sudo bmaptool copy ./full.img <path_to_your_sd_card_like_/dev/sdX>
```
Setup the u-boot environment to run from SD-card by default.
- Start serial terminal `minicom -b 115200 /dev/ttyUSB0`.
- Turn on the board.
- Wait few seconds until u-boot prrints "Hit any key to stop autoboot".
- Press Enter and see "=>" u-boot prompt.
- Set boot from SD-card as default for u-boot `setenv bootcmd run bootcmd_mmc0`
- Save modified u-boot environmemnt `saveenv`.
- Reboot the board.

### Run on eMMC
Use experimental script image_flasher.
Get script
```
wget https://raw.githubusercontent.com/rshym/image_flasher/main/image_flasher.py
```

Run it like this
```
sudo ./image_flasher.py -t -s /dev/ttyUSB0 full.img
```
The root rights are required because image_flasher needs to start own TFTP server on port 69.

Setup the u-boot environment to run from SD-card by default.
- Start serial terminal `minicom -b 115200 /dev/ttyUSB0`.
- Turn on the board.
- Wait few seconds until u-boot prrints "Hit any key to stop autoboot".
- Press Enter and see "=>" u-boot prompt.
- Set boot from SD-card as default for u-boot `setenv bootcmd run bootcmd_emmc`
- Save modified u-boot environmemnt `saveenv`.
- Reboot the board.


## What to do on the board

Use `root` to login to Dom0 or DomD.

The mostly used program inside Dom0 is `xl`. Examples of usage:
```
xl list                         - list running domains
xl console DomD                 - switch to DomD's console (press Ctrl-5 to return to Dom0)
xl destroy DomU                 - destroy DomU
xl create /etc/xen/domd.cfg -c  - create DomU and switch to it's console
```

Detailed manual for `xl` you can find at https://xenbits.xen.org/docs/unstable/man/xl.1.html

The DomD contains quite regular Linux so you can use lots of regular Linux tools.

Also, pay attention that DomD is home for backend drivers for guest domains like DomU or DomA. This means that DomU/DomA is working with real hardware using drivers in DomD. And if you stop network in DomD, DomU/DomA will be isolated from the world as well.

If you want to return to Dom0 from any other domain - use `Ctrl-5`.

