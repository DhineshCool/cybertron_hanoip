#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bndan Prakoso (rama982)
# Android Kernel Build Script

yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
gre='\e[0;32m'

# Main environtment
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz
ZIP_DIR=$KERNEL_DIR/../anykernel3
CONFIG=vendor/hanoip_defconfig
CROSS_COMPILE="aarch64-linux-android-"
CROSS_COMPILE_ARM32="arm-linux-androideabi-"
PATH="${KERNEL_DIR}/../cl14/bin:${KERNEL_DIR}/../aarch64-linux-android-4.9/bin:${KERNEL_DIR}/../arm-linux-androideabi-4.9/bin:${PATH}"

# Export
export LOCALVERSION=-Cybertron-v2.1

export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64
export CROSS_COMPILE
export CROSS_COMPILE_ARM32

export KBUILD_BUILD_HOST="mint"
export KBUILD_BUILD_USER="cool585"

# Build start
Start=$(date +"%s")

make O=out $CONFIG
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \
CLANG_TRIPLE=aarch64-linux-gnu- \
CROSS_COMPILE=aarch64-linux-android- | tee build.log

exit_code=$?
End=$(date +"%s")
Diff=$(($End - $Start))

if [ -f $KERN_IMG ]; then
	mkdir -p $ZIP_DIR
	cp -f ./out/arch/arm64/boot/Image.gz $ZIP_DIR/Image.gz
	cp -f ./out/arch/arm64/boot/dts/qcom/sdmmagpie-hanoi-base.dtb $ZIP_DIR/dtb
	cp -f ./out/arch/arm64/boot/dtbo.img $ZIP_DIR/dtbo.img
	which avbtool &>/dev/null && python2 `which avbtool` add_hash_footer \
		--partition_name dtbo \
		--partition_size $((32 * 1024 * 1024)) \
		--image $ZIP_DIR/dtbo.img
	echo -e "$gre << Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds >> \n $white"
else
	echo -e "$red << Failed to compile Image.gz-dtb, fix the errors first >>$white"
	exit $exit_code
fi

cd $ZIP_DIR
make clean &>/dev/null
make normal &>/dev/null
rm -rf hanoip.zip hanoip-signed.zip zipsigner-3.0.jar

echo -e "$yellow || Signing Zip || $white"

zip -r9 hanoip.zip * -x .git README.md *placeholder
curl -sLo zipsigner-3.0.jar https://github.com/Magisk-Modules-Repo/zipsigner/raw/master/bin/zipsigner-3.0-dexed.jar
java -jar zipsigner-3.0.jar hanoip.zip hanoip-signed.zip

echo -e "$gre || Flashable zip generated under $ZIP_DIR. ||"
cd ..
# Build end
