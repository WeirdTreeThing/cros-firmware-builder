coreboot_url="https://github.com/MrChromebox/coreboot"
coreboot_tag="MrChromebox-4.22.2"

function get_coreboot_config()
{
    board=$1

    jq -r ".${board}.coreboot" "${ROOT}/boards.json"
}

function clone_coreboot()
{
    git clone $coreboot_url -b $coreboot_tag $ROOT/sources/coreboot
    pushd $ROOT/sources/coreboot
    make crossgcc-i386 CPUS=$(nproc)
    popd
}

function install_coreboot()
{
    board=$1

    mkdir -p $ROOT/build/$board/coreboot
    cp build/coreboot.rom $ROOT/build/$board/coreboot/
    cp build/static_fw_config.h $ROOT/build/$board/coreboot/
    cp build/cbfstool $ROOT/build/$board/coreboot
    cp util/archive/archive $ROOT/build/$board/coreboot
}

function build_coreboot()
{
    board=$1
    config=$(get_coreboot_config $board)

    [ ! -d $ROOT/sources/coreboot ] && clone_coreboot
    pushd $ROOT/sources/coreboot
    git reset --hard
    git clean -df
    for patch in $ROOT/patches/coreboot/*; do
        patch -p1 < $patch
    done
    make distclean
    cp $ROOT/configs/coreboot/$board.config .config
    make olddefconfig
    make -j$(nproc)
    pushd util/archive
    make
    popd
    install_coreboot $board
    popd
}
