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

function add_assets()
{
    board=$1
    rom=$2

    for file in $ROOT/build/$board/assets/ro/*; do
	    $cbfstool $rom add -r COREBOOT -f $file -n "$(basename $file)" -t raw -c lzma
    done
}

function agesa_rw()
{
    board=$1
    rom=$2

    $cbfstool $rom extract -n AGESA -f $ROOT/build/$board/AGESA
    $cbfstool $rom add -n AGESA -f $ROOT/build/$board/AGESA -r FW_MAIN_A,FW_MAIN_B -t raw
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

    # Add firmware assets
    add_assets $board $out

    # Some AMD platforms may need AGESA in both RO and RW firmware
    $cbfstool $out print | grep AGESA && agesa_rw $board $out

    sign_image $out
}
