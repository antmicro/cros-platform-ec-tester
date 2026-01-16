*** Variables ***
${SCRIPT_PATH}                      ${CURDIR}/../../sanok.resc
${BINS_PATH}                        ${CURDIR}/../test-bins
${TIMEOUT}                          %TIMEOUT%
${UART}                             sysbus.%UART%

*** Keywords ***
Create Machine With Bins From ${bin_path}
    Execute Command                 $bin=@${bin_path}
    Execute Command                 include @${SCRIPT_PATH}

    Create Terminal Tester          ${UART}  timeout=0.1  defaultPauseEmulation=true

Boot EC With Bins From ${bin_path}
    Create Machine With Bins From ${bin_path}

    Wait For Line On Uart           ![Image: RO, sanok
    Wait For Line On Uart           Jumping to image RW  timeout=2
    Wait For Line On Uart           ![Image: RW, sanok  timeout=1

Run UART Command
    [Arguments]                     ${command}
    Wait For Prompt On Uart         fpmcu:~$
    Write Line To Uart              ${command}

Verify Test Binaries
    [Arguments]                     ${test_bins}
    ${bin_exists}=                  Run Keyword And Return Status  File Should Exist  ${test_bins}/ec.bin
    ${rw_exists}=                   Run Keyword And Return Status  File Should Exist  ${test_bins}/zephyr.rw.elf
    ${ro_exists}=                   Run Keyword And Return Status  File Should Exist  ${test_bins}/zephyr.ro.elf

    ${missing}=                     Evaluate  ([name for name, exists in [('ec.bin', ${bin_exists}), ('zephyr.rw.elf', ${rw_exists}), ('zephyr.ro.elf', ${ro_exists})] if not exists])
    IF  ${missing}
        Skip                            Missing test bins: ${missing}
    END

Run Test Suite
    [Arguments]                     ${test_bins}
    ${bin_path}=                    Join Path  ${BINS_PATH}  ${test_bins}
    Verify Test Binaries            ${bin_path}

    Boot EC With Bins From ${bin_path}

    # Check for ztest existence.
    Register Failing Uart String    ztest: command not found

    # Just for clarity.
    Run UART Command                ztest list-testcases

    Run UART Command                ztest run-all

    # Ensure the test actually starts.
    Wait For Line On Uart           Running TESTSUITE

    # Fail immediately on test failure.
    Register Failing Uart String    PROJECT EXECUTION FAILED

    Wait For Line On Uart           PROJECT EXECUTION SUCCESSFUL  timeout=30

*** Test Cases ***
Should Pass Test Suite
    Run Test Suite                  %TEST_NAME%
