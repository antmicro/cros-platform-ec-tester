*** Variables ***
${PLATFORM}                   %PLATFORM%
${SCRIPT}                     ${CURDIR}/${PLATFORM}.resc
${BIN_PATH}                   ${CURDIR}/${PLATFORM}
${TESTS_PATH}                 ${BIN_PATH}/tests
${TIMEOUT}                    %TIMEOUT%
@{pattern}                    test-*.bin
${MPU_FAILURE_MESSAGE}        Data access violation, mfar =

*** Keywords ***
Create Machine
    [Arguments]               ${test}
    Execute Command           $bin=@${TESTS_PATH}/test-${test}.bin
    Execute Command           $elf_ro=@${TESTS_PATH}/${test}.RO.elf
    Execute Command           $elf_rw=@${TESTS_PATH}/${test}.RW.elf
    Execute Script            ${SCRIPT}
    Execute Command           logFile $ORIGIN/logs/%PLATFORM%-${test}.log
    Create Terminal Tester    sysbus.%USART%  timeout=${TIMEOUT}  defaultPauseEmulation=True

Wait For System Prompt
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP: The AP is failing to respond because it is sleeping or off
    Write Line To Uart
    Wait For Prompt On Uart   >

Start To Prompt
    [Arguments]               ${test}
    Reset Emulation
    ${test}=                  Get Substring  ${test}  5  -4
    Create Machine            ${test}
    Start Emulation
    Wait For System Prompt

Run Test
    [Arguments]               ${test}   ${argument}=${EMPTY}   ${message}=Pass!
    Start To Prompt           ${test}
    Write Line To Uart        runtest ${argument}
    Wait For Line On Uart     ${message}

Start In RO
    [Arguments]               ${test}
    Start To Prompt           ${test}
    Write Line To Uart        reboot ro
    Wait For System Prompt

Run Test In RO
    [Arguments]               ${test}   ${argument}=${EMPTY}   ${message}=Pass!
    Start In RO               ${test}
    Write Line To Uart        runtest ${argument}
    Wait For Line On Uart     ${message}

*** Test Cases ***
