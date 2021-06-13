Pre-requisites (need to be installed on this system to build universal FFmpeg binaries) :

1 - Xcode 12 or a later version
2 - Homebrew (Download instructions here: https://brew.sh/)
3 - nasm - assembler for x86 (Run "brew install nasm" ... after installing Homebrew)
4 - clang - C compiler (Run "xcode-select --install")
5 - pkg-config (Run "brew install pkg-config")

Instructions to build FFmpeg shared libaries (.dylib) from source.

NOTE - Pay attention to licensing requirements / considerations if / when distributing these libraries.

1 - Open a terminal window

2 - cd to the directory containing this README.txt file (and the FFmpeg build script and source code archive). This step is important. The build script will assume that you have done this and will not work otherwise.

3 - Run "./build-ffmpeg.sh" and wait till it is finished executing

4 - The newly built FFmpeg shared libraries will be in the subdirectory "sharedLibs"
(there should be 4: 1 - libavcodec.(version).dylib, 2 - libavformat.(version).dylib, 3 - libavutil.(version).dylib, 4 - libswresample.(version).dylib)

5 - Copy the shared libraries into the Frameworks group in the Xcode project (replace existing files).
