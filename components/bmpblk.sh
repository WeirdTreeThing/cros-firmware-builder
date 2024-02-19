bmpblk_url="https://chromium.googlesource.com/chromiumos/platform/bmpblk"
bmpblk_branch="main"
grit_url="https://chromium.googlesource.com/chromium/src/tools/grit.git"

function clone_bmpblk()
{
    git clone $bmpblk_url -b $bmpblk_branch $ROOT/sources/bmpblk
}

function get_bmpblk_config()
{
    board=$1

    jq -r ".${board}.bmpblk" "${ROOT}/boards.json"
}

function create_venv()
{
    python -m venv bmpblk-venv
    source bmpblk-venv/bin/activate
    pip install pillow
    pip install pyyaml
    pip install "grit @ git+$grit_url"
}

function install_fonts()
{
    mkdir fonts
    pushd fonts
    curl -L "https://gwfh.mranftl.com/api/fonts/cousine?download=zip&subsets=latin&variants=regular&formats=ttf" -o cousine-v27-latin.zip # This is the best way I've found to download google fonts
    curl -LO "https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/notofonts-20231207.tar.xz"
    unzip cousine-v27-latin.zip
    tar xf notofonts-20231207.tar.xz
    cat > local-conf.xml <<-EOF
	<?xml version="1.0"?>
	<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
	<fontconfig>
	<cachedir>${PWD}</cachedir>
	<dir>${PWD}</dir>
	<include>/etc/fonts/fonts.conf</include>
	</fontconfig>
	EOF
    export FONTCONFIG_FILE=${PWD}/local-conf.xml
    fc-cache -v
    popd
}

function install_bmpblk()
{
    board=$1
    build_target=$2

    mkdir -p $ROOT/build/$board/assets/{ro,rw}
    cp $ROOT/build/$board/bmpblk/$build_target/{font,vbgfx}.bin $ROOT/build/$board/assets/ro
    cp $ROOT/build/$board/bmpblk/$build_target/locale/ro/*.bin $ROOT/build/$board/assets/ro
    cp $ROOT/build/$board/bmpblk/$build_target/locales $ROOT/build/$board/assets/ro
}

function build_bmpblk()
{
    board=$1
    config=$(get_bmpblk_config $board)

    [ ! -d "$ROOT/sources/bmpblk" ] && clone_bmpblk

    pushd $ROOT/sources/bmpblk
    [ ! -d "bmpblk-venv" ] && create_venv
    [ ! -d "fonts" ] && install_fonts
    export FONTCONFIG_FILE="${PWD}/fonts/local-conf.xml"
    source bmpblk-venv/bin/activate
    export PHYSICAL_PRESENCE="keyboard"
    mkdir -p $ROOT/build/$board/bmpblk
    make OUTPUT="$ROOT/build/$board/bmpblk" BOARD="$config"
    make OUTPUT="$ROOT/build/$board/bmpblk/$config" ARCHIVER="$ROOT/build/$board/coreboot/archive" archive
    install_bmpblk $board $config
    popd
}
