#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bndan Prakoso (rama982)
# Android Kernel Build Script


# Main environtment
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz
ZIP_DIR=$KERNEL_DIR/../anykernel
CONFIG=vendor/hanoip_defconfig
CROSS_COMPILE="aarch64-linux-android-"
CROSS_COMPILE_ARM32="arm-linux-androideabi-"
PATH="${KERNEL_DIR}/../cl12/bin:${KERNEL_DIR}/../aarch64-linux-android-4.9/bin:${KERNEL_DIR}/../arm-linux-androideabi-4.9/bin:${PATH}"

# Export
export ARCH=arm64
export CROSS_COMPILE
export CROSS_COMPILE_ARM32

# Build start
make O=out $CONFIG
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-linux-android- | tee build.log

if ! [ -a $KERN_IMG ]; then
    echo "Build error!"
    exit 1
fi

cd $ZIP_DIR
make clean &>/dev/null
cd ..
cd $ZIP_DIR
cp $KERN_IMG zImage
make normal &>/dev/null
rm -rf hanoip.zip
zip -r9 hanoip.zip * -x .git README.md *placeholder
echo "Flashable zip generated under $ZIP_DIR."
cd ..
# Build end
