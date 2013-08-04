#!/bin/sh

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


WorkSpaceRoot=`pwd`
OpenSSLMirroDir=$WorkSpaceRoot/opensslmirror
FFMpegMirrorDir=$WorkSpaceRoot/ffmpegmirror
TMP=/tmp/build_23432sfs342f3.$$ && mkdir -p $TMP


# $1	name
# $2	version
# $3	url
# $4	wget args
# $5	tar args
function install_source_tools()
{
	name="$1"; ver="$2"; url="$3"; wgetargs="$4"; tarargs="$5";
	dir=$name
	type "$name" >/dev/null 2>&1
	if [[ $? != 0 ]]; then
		echo "INFO: install \`$name' ..."
		[[ ! -z $ver ]] && dir=$name-$ver
		cd $TMP && rm -rf $dir && mkdir -p $dir
		[[ ! -e ${url##*/} ]] && wget --no-check-certificate $wgetargs "$url"
		tar $tarargs ${url##*/}
		cd $dir
		./configure --prefix=$HOME
		(make clean && make && make install)
	else
		echo "WARNING: \`$name' have installed!"
	fi
}

# $1	name
# $2	url
# $3	wget args
function install_execute_tools()
{
	name="$1"; url="$2"; wgetargs="$3";
	dest=$HOME/bin && mkdir -p $dest
	type "$name" >/dev/null 2>&1
	if [[ $? != 0 ]]; then
		echo "INFO: install \`$name' ..."
		cd $TMP
		[[ ! -e ${url##*/} ]] && wget --no-check-certificate $wgetargs "$url"
		chmod +x ${url##*/} && cp -Rf ${url##*/} $dest
	else
		echo "WARNING: \`$name' have installed!"
	fi
}


function build_openssl()
{
	[[ ! -e $OpenSSLMirroDir ]] && {
		cd $WorkSpaceRoot && git clone https://github.com/openssl/openssl.git ${OpenSSLMirroDir##*/}
	}
	cd $OpenSSLMirroDir
	ln -s -f ../build_openssl.sh ./build_openssl.sh
	./build_openssl.sh
}

function build_ffmpeg()
{
	[[ ! -e $FFMpegMirrorDir ]] && {
		cd $WorkSpaceRoot && git clone git://source.ffmpeg.org/ffmpeg.git ${FFMpegMirrorDir##*/}
	}
	cd $FFMpegMirrorDir
	git checkout n2.0
	ln -s -f ../build_ffmepg.sh ./build_ffmepg.sh
	./build_ffmepg.sh
}


######### main #########

install_source_tools "ccache" "3.1.9" "http://samba.org/ftp/ccache/ccache-3.1.9.tar.bz2" "" "xjvf" || kill $$
install_execute_tools "gas-preprocessor.pl" "https://raw.github.com/yuvi/gas-preprocessor/master/gas-preprocessor.pl" "" || kill $$

build_openssl || kill $$
build_ffmpeg || kill $$


exit 0
