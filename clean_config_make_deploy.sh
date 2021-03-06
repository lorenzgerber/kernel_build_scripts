#!/bin/bash
set -x
export KERNEL=kernel
export KERNEL_PATH=/home/lgerber/git/linux_kernel
export TOOL_PATH=/usr/local/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin
export AUTO_MOUNT_SDB1=/media/lgerber/boot
export AUTO_MOUNT_SDB2=/media/lgerber/28590797-4810-4851-b4ec-bf9672c2918c
export SD1=/dev/sdb1
export SD2=/dev/sdb2
export MOUNT_FAT32=mnt/fat32
export MOUNT_EXT4=mnt/ext4
export NUMBER_CORES=4

cd ${KERNEL_PATH}

#clean up
sudo make ARCH=arm CROSS_COMPILE=${TOOL_PATH}/arm-linux-gnueabihf- distclean

# config
make ARCH=arm CROSS_COMPILE=${TOOL_PATH}/arm-linux-gnueabihf- bcmrpi_defconfig

# make
make -j ${NUMBER_CORES} ARCH=arm CROSS_COMPILE=${TOOL_PATH}/arm-linux-gnueabihf- zImage modules dtbs > makelog.txt
#unmount automounted SD
umount ${AUTO_MOUNT_SDB1}
umount ${AUTO_MOUNT_SDB2}

#mount in repo
sudo mount ${SD1} ${MOUNT_FAT32}
sudo mount ${SD2} ${MOUNT_EXT4}

#install modules
sudo make ARCH=arm CROSS_COMPILE=${TOOL_PATH}/arm-linux-gnueabihf- INSTALL_MOD_PATH=${MOUNT_EXT4} modules_install

#install firmware
sudo make ARCH=arm CROSS_COMPILE=${TOOL_PATH}/arm-linux-gnueabihf- INSTALL_FW_PATH=${MOUNT_FAT32} firmware_install

#install headers
sudo make ARCH=arm CROSS_COMPILE=${TOOL_PATH}/arm-linux-gnueabihf- INSTALL_HDR_PATH=${MOUNT_EXT4}/usr headers_install

#backup / copy Kernel
sudo cp ${MOUNT_FAT32}/$KERNEL.img ${MOUNT_FAT32}/$KERNEL-backup.img
sudo cp arch/arm/boot/zImage ${MOUNT_FAT32}/$KERNEL.img
sudo cp arch/arm/boot/dts/*.dtb ${MOUNT_FAT32}/
sudo cp arch/arm/boot/dts/overlays/*.dtb* ${MOUNT_FAT32}/overlays/
sudo cp arch/arm/boot/dts/overlays/README ${MOUNT_FAT32}/overlays/
sudo umount ${MOUNT_FAT32}
sudo umount ${MOUNT_EXT4}
