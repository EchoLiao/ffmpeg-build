#!/bin/bash

#set -x

[[ ! -e $HOME/build_ios_local.sh ]] && {
	echo "File \"$HOME/build_ios_local.sh\" not found! Pls see 'build_ios_local.sh.sample'!!" 2>&1
	exit 1;
}
source $HOME/build_ios_local.sh

pwd | grep -q '[[:blank:]]' && {
	echo "Source path: $(pwd)"
	echo "Out of tree builds are impossible with whitespace in source path."
	exit 1;
}


export DEVRootReal="${DEVELOPER}/Platforms/iPhoneOS.platform/Developer"
export SDKRootReal="${DEVRootReal}/SDKs/iPhoneOS${SDKVERSION}.sdk"
export DEVRootSimulator="${DEVELOPER}/Platforms/iPhoneSimulator.platform/Developer"
export SDKRootSimulator="${DEVRootSimulator}/SDKs/iPhoneSimulator${SDKVERSION}.sdk"
export PATH=$HOME/bin:$PATH

SOURCE=`pwd`
DEST=`pwd`/build/ios && rm -rf $DEST


build()
{
	VER=$1; ARCH=$2; GCC=$3; SDK=$4; CONFARGS=$5; SSLDIR=$6;
	log=${SSLDIR}/build.log && rm -rf ${log}
	cd $SOURCE
	./Configure BSD-generic32 ${CONFARGS} --openssldir="${SSLDIR}" 2>&1 | tee -a ${log}
	perl -i -pe 's|static volatile sig_atomic_t intr_signal|static volatile int intr_signal|' crypto/ui/ui_openssl.c
	perl -i -pe "s|^CC= gcc|CC= ${GCC} -arch ${ARCH}|g" Makefile
	perl -i -pe "s|^CFLAG= (.*)|CFLAG= -pipe -isysroot ${SDK} \$1|g" Makefile
	(make clean && make && make install) 2>&1 | tee -a ${log}; [[ $PIPESTATUS != 0 ]] && kill $$
}

build_versions="release"
build_archs="armv7 armv7s i386"
path_old=$PATH

for iver in $build_versions; do
	lipo_ssl_args=; lipo_crypto_args=;
	for iarch in $build_archs; do
		case $iarch in
			armv7|armv7s)
				export PATH=${DEVRootReal}/usr/bin:$path_old
				cc="${DEVRootReal}/usr/bin/gcc"
				sdk="${SDKRootReal}"
				;;
			i386)
				export PATH=${DEVRootSimulator}/usr/bin:$path_old
				cc="${DEVRootSimulator}/usr/bin/gcc"
				sdk="${SDKRootSimulator}"
				confargs="386"
				;;
		esac
		ssldir=${DEST}/$iver/$iarch && mkdir -p $ssldir
		build "$iver" "$iarch" "$cc" "$sdk" "$confargs" "$ssldir"
		lipo_ssl_args="$lipo_ssl_args $ssldir/lib/libssl.a"
		lipo_crypto_args="$lipo_crypto_args $ssldir/lib/libcrypto.a"
	done
	export PATH=${DEVRootReal}/usr/bin:$path_old
	univs=${DEST}/$iver/universal/ && mkdir -p $univs
	univslib=$univs/lib && mkdir -p $univslib
	cp -Rf ${DEST}/$iver/$iarch/include $univs/
	lipo $lipo_ssl_args -create -output $univslib/libssl.a
	lipo $lipo_crypto_args -create -output $univslib/libcrypto.a
	libtool -static -o $univslib/libopenssl.a -L$univslib -lcrypto -lssl
	ranlib $univslib/libopenssl.a
done


###### Reference ######
# https://github.com/st3fan/ios-openssl/blob/master/build.sh

exit 0
