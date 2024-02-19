cros_ec_url="https://chromium.googlesource.com/chromiumos/platform/ec"
cros_ec_branch="main"

function clone_cros_ec()
{
    git clone $cros_ec_url -b $cros_ec_branch $ROOT/sources/ec
}

function install_ec_headers()
{
    [ ! -d $ROOT/sources/ec ] && clone_cros_ec

    mkdir -p $ROOT/build/ec_headers/
    pushd $ROOT/sources/ec
    cp include/ec_commands.h $ROOT/build/ec_headers
    cp include/ec_cmd_api.h $ROOT/build/ec_headers
    cp include/panic_defs.h $ROOT/build/ec_headers
    cp util/cros_ec_dev.h $ROOT/build/ec_headers
    popd
}
