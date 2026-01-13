#!/usr/bin/env bash

set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes

tests_raw="$1"
output_dir_raw="$2"
board="sanok"

# Strip brackets and quotes, split on commas
tests_raw="${tests_raw#[}"
tests_raw="${tests_raw%]}"
tests_raw="${tests_raw//\'/}"
IFS=', ' read -r -a tests <<<"$tests_raw"

output_dir=$(realpath "${output_dir_raw}")

declare -A results
results[SUCCESS]=""
results[FAILED]=""
results[SKIPPED]=""
results[NO_OUTPUT]=""
results[UNKNOWN]=""

test_count=0
total_tests=${#tests[@]}

for test_name in "${tests[@]}"; do
    test_count=$((test_count + 1))

    # Use a uniquely named directory, so the tests don't overwrite each other.
    test_bin_output_dir="${output_dir}/${test_name}"
    mkdir -p "${test_bin_output_dir}"

    build_log="${test_bin_output_dir}/build_log.txt"

    echo "Building '${test_name}'... ($test_count/$total_tests)"

    cros_sdk -- bash -c \
        "cd ../platform/ec && ./test/run_device_tests.py --board $board --zephyr -t $test_name" \
        >"${build_log}" 2>&1 ||
        true # The run_device_tests script always fails since it can't run the test.

    if grep -q "ERROR:failed to build" "${build_log}"; then
        echo "  FAILED"
        results[FAILED]+="${test_name} "
    elif grep -qE 'Test ".*": SKIPPED' "${build_log}"; then
        echo "  SKIPPED"
        results[SKIPPED]+="${test_name} "
    elif ! ls build/zephyr/$board/output/* >/dev/null 2>&1; then
        echo "  NO OUTPUT"
        results[NO_OUTPUT]+="${test_name} "
    elif grep -q 'INFO:Flashing test' "${build_log}"; then # If the script tries to flash, then build succeeded
        mv build/zephyr/$board/output/* "${test_bin_output_dir}"
        echo "  SUCCESS"
        results[SUCCESS]+="${test_name} "
    else
        echo "  UNKNOWN"
        results[UNKNOWN]+="${test_name} "
    fi
    echo ""

done

echo "=========================================="
echo "        $board TEST BUILD SUMMARY"
echo "=========================================="
echo ""

for category in "SUCCESS" "FAILED" "SKIPPED" "NO_OUTPUT" "UNKNOWN"; do
    read -r -a test_names <<<"${results[$category]}"
    count=${#test_names[@]}

    if [ "$count" -eq 0 ]; then
        continue
    fi

    echo "${category} (${count})"
    if [ "$count" -gt 0 ]; then
        for t in "${test_names[@]}"; do
            echo "  - $t"
        done
    fi
    echo ""
done

echo "Test logs and artifacts can be found in:"
echo "  ${output_dir}"
