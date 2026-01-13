copy_artifacts() {
    # $1 - board name
    mkdir -p "artifacts/$1"
    find "artifacts-raw/build/$1" \( -iname 'test-*.bin' -o -iname '*.RO.elf' -o -iname '*.RW.elf' \) -exec cp '{}' "artifacts/$1" \;
}

copy_test_artifacts() {
    # $1 - board name
    mkdir -p "artifacts/$1"
    cp -r "artifacts-raw/$1-test-bins/"*/ "artifacts/$1/"
}

copy_artifacts_zephyr() {
    # $1 - board name
    # $2 - list of additional files to find, passed as string of ';' separated strings: "key.vbprik2;ec.config"
    mkdir -p "artifacts/$1"
    # Fetching build dependencies for Zephyr based targets is flaky on CI. Don't fail the entire pipeline if the binaries couldn't be built
    find "artifacts-raw/build/zephyr/$1/output" \( -iname '*.bin' -o -iname '*.ro.elf' -o -iname '*.rw.elf' \) -exec cp '{}' "artifacts/$1" \; || true

    IFS=';' read -r -a extra_files <<<"$2"
    for f in "${extra_files[@]}"; do
        [ -z "$f" ] && continue
        find "artifacts-raw/build/zephyr/$1/output" -iname "$f" -exec cp '{}' "artifacts/$1" \; || true
    done
}
