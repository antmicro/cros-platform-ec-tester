*** Settings ***
Suite Setup                   Setup
Suite Teardown                Teardown
Test Setup                    Reset Emulation
Test Teardown                 Test Teardown
Resource                      ${RENODEKEYWORDS}

*** Variables ***
${PLATFORM}                   %PLATFORM%
${SCRIPT}                     ${CURDIR}/${PLATFORM}.resc
${BIN_PATH}                   ${CURDIR}/${PLATFORM}
${TESTS_PATH}                 ${BIN_PATH}/tests
${TIMEOUT}                    %TIMEOUT%
@{pattern}                    test-*.bin

*** Keywords ***
Create Machine
    [Arguments]               ${test}
    Execute Command           $bin=@${TESTS_PATH}/test-${test}.bin
    Execute Command           $elf_ro=@${TESTS_PATH}/${test}.RO.elf
    Execute Command           $elf_rw=@${TESTS_PATH}/${test}.RW.elf
    Execute Script            ${SCRIPT}
    Execute Command           logFile $ORIGIN/logs/%PLATFORM%-${test}.log
    Create Terminal Tester    sysbus.%USART%  timeout=${TIMEOUT}


Start To Prompt
    [Arguments]               ${test}
    Reset Emulation
    ${test}=                  Get Substring  ${test}  5  -4
    Create Machine            ${test}
    Start Emulation
    Wait For Line On Uart     Image: RW
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP not cleared within threshold
    Write Line To Uart
    Wait For Prompt On Uart   >

Run Test
    [Arguments]               ${test}   ${argument}=${EMPTY}
    Start To Prompt           ${test}
    Write Line To Uart        runtest ${argument}
    Wait For Line On Uart     Pass!

*** Test Cases ***
