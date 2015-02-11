#!/bin/sh
# Scripts assume their pwd is their location:
cd ${0%/*}

# Check OS:
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        ./build_srLua_linux.sh
elif [[ "$OSTYPE" == "darwin"* ]]; then
        ./build_srLua_osx.sh
elif [[ "$OSTYPE" == "cygwin" ]]; then
        ./build_srLua_cygwin.sh
elif [[ "$OSTYPE" == "msys" ]]; then
        ./build_srLua_msys.sh
elif [[ "$OSTYPE" == "win32" ]]; then
		# Shouldn't be possible but..
        ./build_srLua_win32.bat
fi