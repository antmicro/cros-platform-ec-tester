copy_artifacts() {
    # $1 - board name
    mkdir -p "artifacts/$1"
    find "artifacts-raw/build/$1" \( -iname 'test-*.bin' -o -iname '*.RO.elf' -o -iname '*.RW.elf' \) -exec cp '{}' "artifacts/$1" \;
}

copy_artifacts_zephyr() {
    # $1 - board name
    mkdir -p "artifacts/$1"
    find "artifacts-raw/build/zephyr/$1/output" \( -iname '*.bin' -o -iname '*.ro.elf' -o -iname '*.rw.elf' \) -exec cp '{}' "artifacts/$1" \;
}
