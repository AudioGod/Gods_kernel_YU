#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image"
DTBIMAGE="dtb"
DEFCONFIG="gk_tomato_defconfig"

#GK Kernel Details
VER="-MR-1.3-tomato-$(date +"%Y%m%d")"
GK_VER="$BASE_GK_VER$VER$TC"

# Vars
BASE_GK_VER="GK"
GK_VER="$BASE_GK_VER$VER$TC"
export LOCALVERSION=~`echo $GK_VER`
export LOCALVERSION=~`echo $GK_VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=AudioGod
export KBUILD_BUILD_HOST=Sungsonic

# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="$KERNEL_DIR/.."
ANYKERNEL_DIR="$RESOURCE_DIR/GK-Tomato-AnyKernel2"
TOOLCHAIN_DIR="/home/adi/kernels"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/GK-releases"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm64/boot"

# Functions
function clean_all {
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf ${HOME}/kernels/Gods_kernel_YU/arch/arm64/boot/dt.img
		cd ${HOME}/kernels/GK-Tomato-AnyKernel2/
		rm -rf zImage
		rm -rf $DTBIMAGE
		rm -rf $KERNEL
		git reset --hard > /dev/null 2>&1
		git clean -f -d > /dev/null 2>&1
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		make $DEFCONFIG
		make $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

function make_modules {
		if [ -f "$MODULES_DIR/*.ko" ]; then
			rm `echo $MODULES_DIR"/*.ko"`
		fi
		#find $MODULES_DIR/proprietary -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
		cd $MODULES_DIR
        $STRIP --strip-unneeded *.ko
        cd $KERNEL_DIR
}

function make_dtb {
		$REPACK_DIR/tools/dtbToolCM -v2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
		cp -vr $KERNEL_DIR/arch/arm64/boot/dt.img $REPACK_DIR/dtb
}

function make_zip {
		cd $REPACK_DIR
		zip -x@zipexclude -r9 `echo $GK_VER`.zip *
		mv  `echo $GK_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

DATE_START=$(date +"%s")


echo -e "${green}"
echo "--------------------------------------------------------"
echo "Wellcome !!!   Initiatig To Compile $BASE_GK_VER$VER    "
echo "--------------------------------------------------------"
echo -e "${restore}"

echo -e "${cyan}"
while read -p "Plese Select Desired Toolchain for compiling God's Kernel

UBERTC-6.0---->(1)

UBERTC-4.9---->(2)

UBERTC-5.2---->(3)

SaberMod-6.0-->(4)

Linaro-5.2---->(5)

" echoice
do
case "$echoice" in
	1 )
		export CROSS_COMPILE=${HOME}/kernels/aarch64-linux-android-6.0-UBERTC/bin/aarch64-linux-android-
		STRIP=${HOME}/kernels/aarch64-linux-android-6.0-UBERTC/bin/aarch64-linux-android-strip
		TC="UBERTC-6.0"
		echo
		echo "Compiling God's Kernel Using UBERTC-6.0 Toolchain"
		break
		;;
	2 )
		export CROSS_COMPILE=${HOME}/kernels/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-
		STRIP=${HOME}/kernels/aarch64-linux-android-4.9-UBERTC/bin/aarch64-linux-android-strip
		TC="UBERTC-4.9"
		echo
		echo "Compiling God's Kernel Using UBERTC-4.9 Toolchain"
		break
		;;
	3 )
		export CROSS_COMPILE=${HOME}/kernels/aarch64-linux-android-5.2-UBERTC/bin/aarch64-linux-android-
		STRIP=${HOME}/kernels/aarch64-linux-android-5.2-UBERTC/bin/aarch64-linux-android-strip
		TC="UBERTC-5.2"
		echo
		echo "Compiling God's Kernel Using UBERTC-5.2 Toolchain"
		break
		;;			
	4 )
		export CROSS_COMPILE=${HOME}/kernels/aarch64-linux-gnu-6.0SM/bin/aarch64-
		STRIP=${HOME}/kernels/aarch64-linux-gnu-6.0SM/bin/aarch64-strip
		TC="SM-6.0"
		echo
		echo "Compiling God's Kernel Using Saber Mod-6.0 Toolchain"
		break
		;;
	5 )
		export CROSS_COMPILE=${HOME}/kernels/linaro-arm-eabi-5.2/bin/aarch64-
		TC="LINARO"
		echo
		echo "Compiling God's Kernel Using Linaro-5.2 Toolchain"
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo
echo -e "${red}"
while read -p "Do you want to make clean Build of God's Kernel ? 

Yes Or No ? 

Enter Y for Yes Or N for No

" cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "Cleaning Sucess. Build Directory is clean now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo -e "${cyan}"
while read -p "Do you want to Generate Change-Log ?

Yes Or No ? 

Enter Y for Yes Or N for No

" bchoice
do
case "$bchoice" in
	y|Y )
		./gk_changelog.sh
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo
while read -p "Do you want to start Building God's Kernel ?

Yes Or No ? 

Enter Y for Yes Or N for No

" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_dtb
		make_modules
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${green}"
echo "------------------------------------------"
echo "Build $GK_VER Completed :"
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
