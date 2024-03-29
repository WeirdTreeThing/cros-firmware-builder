#!/bin/bash

set -e

source components/coreboot.sh
source components/ec_headers.sh
source components/libpayload.sh
source components/depthcharge.sh
source components/bootimage.sh
source components/bmpblk.sh

ROOT="${PWD}"

board="$1"
[ -z $board ] && echo "./builder.sh (board)" && exit
mkdir -p "build/${board}"

install_ec_headers

build_coreboot $board
build_libpayload $board
build_depthcharge $board
build_bmpblk $board # TODO: fix the weird looking fonts (fontconfig config?)
make_image $board "coreboot.rom" "$board.rom"
