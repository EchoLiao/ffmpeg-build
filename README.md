****Compile FFMpeg(support OpenSSL) for iOS, support armv7/armv7s/i386 (Universal library).****

The defualt version of building ffmpeg is 2.0 .


## Requirement

- XCode 4.2 or later
- Command Line Tools
- iOS 5.0 or later


## How to use?

### Download

	$ git clone git@github.com:nuoerlz/ffmpeg-build.git

### Custom

Before start building, you need to set the environment value of
`DEVELOPER` and `SDKVERSION` .

	$ cd ffmpeg_build/ios
	$ cp build_ios_local.sh.samba $HOME/build_ios_local.sh
	$ vi $HOME/build_ios_local.sh
	...
	// Configure DEVELOPER & SDKVERSION , e.g.
	//	export DEVELOPER="/Users/nuoerlz/Applications/Xcode.app/Contents/Developer"
	//	export SDKVERSION="6.1"

### Build

	$ ./build.sh


(end)
