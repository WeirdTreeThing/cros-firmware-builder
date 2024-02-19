function add_payload()
{
    board=$1
    name=$2
    payload=$3
    region=$4
    rom=$5

    $cbfstool $rom add-payload -r $region -n $name -f $payload -c lzma
}

function sign_image()
{
    rom=$1

    futility sign \
	    --keyset /usr/share/vboot/devkeys \
	    --version 1 \
	    --flags 0 \
	    $rom
}

function make_image()
{
    board=$1
    rom=$2
    output=$3

    out=$ROOT/build/$board/$output
    cbfstool=$ROOT/build/$board/coreboot/cbfstool

    # Copy input rom to output
    cp $ROOT/build/$board/coreboot/$rom $out

    # Expand FW_MAIN_{A,B}
    $cbfstool $out expand -r FW_MAIN_A,FW_MAIN_B

    # Add depthcharge payload
    add_payload $board "fallback/payload" "$ROOT/build/$board/depthcharge/depthcharge.elf" "COREBOOT" $out
    add_payload $board "fallback/payload" "$ROOT/build/$board/depthcharge/depthcharge.elf" "FW_MAIN_A,FW_MAIN_B" $out

    sign_image $out
}
