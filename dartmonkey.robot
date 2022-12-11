*** Settings ***
Suite Setup                   Get Test Cases
Suite Teardown                Teardown
Test Setup                    Reset Emulation
Test Teardown                 Test Teardown
Resource                      ${RENODEKEYWORDS}

*** Variables ***
${SCRIPT}                     ${CURDIR}/dartmonkey.resc
${BIN_PATH}                   ${CURDIR}/dartmonkey
${TESTS_PATH}                 ${BIN_PATH}/tests
@{pattern}                   test-*.bin

*** Keywords ***
Get Test Cases
    Setup
    @{tests}=                 List Files In Directory  ${TESTS_PATH}  @{pattern}
    Set Suite Variable        @{tests}


Create Machine
    [Arguments]               ${test}
    Execute Command           $bin=@${TESTS_PATH}/test-${test}.bin
    Execute Command           $elf_ro=@${TESTS_PATH}/${test}.RO.elf
    Execute Command           $elf_rw=@${TESTS_PATH}/${test}.RW.elf
    Execute Script            ${SCRIPT}
    Create Terminal Tester    sysbus.usart1


Run Test
    [Arguments]               ${test}
    Reset Emulation
    ${test}=                  Get Substring  ${test}  5  -4
    Log To Console            ${test}
    Create Machine            ${test}
    Start Emulation
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP not cleared within threshold
    Write Line To Uart
    Wait For Prompt On Uart   >
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!


*** Test Cases ***
Should Run Test Cases
    [Template]  Run Test
    FOR  ${test}  IN  @{tests}
        ${test}
    END

