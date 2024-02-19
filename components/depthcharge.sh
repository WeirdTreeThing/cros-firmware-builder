depthcharge_url="https://chromium.googlesource.com/chromiumos/platform/depthcharge"
depthcharge_branch="main"

function get_depthcharge_config()
{
    board=$1

    jq -r ".${board}.depthcharge" "${ROOT}/boards.json"
}

function clone_depthcharge()
{
    git clone $depthcharge_url -b $depthcharge_branch $ROOT/sources/depthcharge
}

function create_venv()
{
    python -m venv depthcharge-venv
    source depthcharge-venv/bin/activate
    pip install kconfiglib
}

function build_depthcharge()
{
    board=$1
    config=$(get_depthcharge_config $board)

    [ ! -d "$ROOT/sources/depthcharge" ] && clone_depthcharge
    pushd $ROOT/sources/depthcharge
    [ ! -d "depthcharge-venv" ] && create_venv
    source depthcharge-venv/bin/activate

    mkdir -p $ROOT/build/$board/depthcharge
    cp $ROOT/build/$board/coreboot/static_fw_config.h $ROOT/build/$board/depthcharge/
    cp $ROOT/sources/depthcharge/board/$board/defconfig $ROOT/build/$board/depthcharge/$board-defconfig
    OPTS=(
        "EC_HEADERS=$ROOT/build/ec_headers"
	"LIBPAYLOAD_DIR=$ROOT/build/$board/libpayload/libpayload"
	"obj=$ROOT/build/$board/depthcharge"
	"DOTCONFIG=$ROOT/build/$board/depthcharge/$board.config"
	"KBUILD_DEFCONFIG=$ROOT/build/$board/depthcharge/$board-defconfig"
    )
    make -j$(nproc) ${OPTS[@]} defconfig
    make -j$(nproc) ${OPTS[@]} depthcharge
    strip $ROOT/build/$board/depthcharge/depthcharge.elf
    popd
}
