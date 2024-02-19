vboot_url="https://chromium.googlesource.com/chromiumos/platform/vboot_reference"
vboot_branch="main"

function get_libpayload_config()
{
    board=$1
    jq -r ".${board}.libpayload" "${ROOT}/boards.json"
}

function clone_vboot()
{
    # Use cros vboot since depthcharge version needs to match vboot version
    git clone $vboot_url -b $vboot_branch $ROOT/sources/vboot
}

function install_libpayload()
{
    board=$1

    make VBOOT_SOURCE="$ROOT/sources/vboot" DOTCONFIG="$ROOT/build/$board/libpayload/$board.config" DESTDIR="$ROOT/build/$board/libpayload" install
}

function build_libpayload()
{
    board=$1
    config=$(get_libpayload_config $board)

    [ ! -d "$ROOT/sources/vboot" ] && clone_vboot
    pushd $ROOT/sources/coreboot/payloads/libpayload
    mkdir -p $ROOT/build/$board/libpayload
    cp $ROOT/configs/libpayload/$config.config $ROOT/build/$board/libpayload/$board.config
    VBOOT_SOURCE="$ROOT/sources/coreboot/3rdparty/vboot" DOTCONFIG="$ROOT/build/$board/libpayload/$board.config" make olddefconfig
    VBOOT_SOURCE="$ROOT/sources/coreboot/3rdparty/vboot" DOTCONFIG="$ROOT/build/$board/libpayload/$board.config" make -j$(nproc)
    install_libpayload $board
    popd
}
