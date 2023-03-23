*** Variables ***
${PLATFORM}                   bloonchipper
${SCRIPT}                     ${CURDIR}/${PLATFORM}.resc
${BIN_PATH}                   ${CURDIR}/${PLATFORM}
${TESTS_PATH}                 ${BIN_PATH}/tests
${TIMEOUT}                    15
@{pattern}                    test-*.bin

*** Keywords ***
Create Machine
    [Arguments]               ${test}
    Execute Command           $bin=@${TESTS_PATH}/test-${test}.bin
    Execute Command           $elf_ro=@${TESTS_PATH}/${test}.RO.elf
    Execute Command           $elf_rw=@${TESTS_PATH}/${test}.RW.elf
    Execute Script            ${SCRIPT}
    Execute Command           logFile $ORIGIN/logs/bloonchipper-${test}.log
    Create Terminal Tester    sysbus.usart2  timeout=${TIMEOUT}


Start To Prompt
    [Arguments]               ${test}
    Reset Emulation
    ${test}=                  Get Substring  ${test}  5  -4
    Create Machine            ${test}
    Start Emulation
    Wait For Line On Uart     Image: RW
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP: The AP is failing to respond despite being powered on.
    Write Line To Uart
    Wait For Prompt On Uart   >

Run Test
    [Arguments]               ${test}   ${argument}=${EMPTY}
    Start To Prompt           ${test}
    Write Line To Uart        runtest ${argument}
    Wait For Line On Uart     Pass!

Start In RO
    [Arguments]               ${test}
    Start To Prompt           ${test}
    Write Line To Uart        reboot ro
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP: The AP is failing to respond despite being powered on.
    Write Line To Uart
    Wait For Prompt On Uart   >

Expect MPU failure
    [Arguments]               ${test}   ${argument}=${EMPTY}
    Start To Prompt           ${test}
    Write Line To Uart        runtest ${argument}
    Wait For Line On Uart     Data access violation, mfar =

*** Test Cases ***

Should Run test-abort.bin
    Run Test                  test-abort.bin


Should Run test-aes.bin
    Run Test                  test-aes.bin


Should Run test-always_memset.bin
    Run Test                  test-always_memset.bin


Should Run test-cec.bin
    Run Test                  test-cec.bin


Should Run test-compile_time_macros.bin
    Run Test                  test-compile_time_macros.bin


Should Run test-cortexm_fpu.bin
    Run Test                  test-cortexm_fpu.bin


Should Run test-crc.bin
    Run Test                  test-crc.bin


Should Run test-exception.bin
    Run Test                  test-exception.bin


Should Run test-flash_physical.bin
    Run Test                  test-flash_physical.bin


Should Run test-ftrapv.bin
    Run Test                  test-ftrapv.bin


Should Run test-global_initialization.bin
    Run Test                  test-global_initialization.bin


Should Run test-libc_printf.bin
    Run Test                  test-libc_printf.bin


Should Run test-libcxx.bin
    Run Test                  test-libcxx.bin


Should Run test-mpu.bin
    Run Test                  test-mpu.bin


Should Run test-mutex.bin
    Run Test                  test-mutex.bin


Should Run test-panic.bin
    Run Test                  test-panic.bin


Should Run test-panic_data.bin
    Run Test                  test-panic_data.bin


Should Run test-pingpong.bin
    Run Test                  test-pingpong.bin


Should Run test-printf.bin
    Run Test                  test-printf.bin


Should Run test-queue.bin
    Run Test                  test-queue.bin


Should Run test-rng_benchmark.bin
    Run Test                  test-rng_benchmark.bin


Should Run test-rsa3.bin
    Run Test                  test-rsa3.bin


Should Run test-rtc.bin
    Run Test                  test-rtc.bin


Should Run test-scratchpad.bin
    Run Test                  test-scratchpad.bin


Should Run test-sha256.bin
    Run Test                  test-sha256.bin


Should Run test-sha256_unrolled.bin
    Run Test                  test-sha256_unrolled.bin


Should Run test-static_if.bin
    Run Test                  test-static_if.bin


Should Run test-std_vector.bin
    Run Test                  test-std_vector.bin


Should Run test-stdlib.bin
    Run Test                  test-stdlib.bin


Should Run test-stm32f_rtc.bin
    Run Test                  test-stm32f_rtc.bin


Should Run test-timer.bin
    Run Test                  test-timer.bin


Should Run test-timer_dos.bin
    Run Test                  test-timer_dos.bin


Should Run test-tpm_seed_clear.bin
    Run Test                  test-tpm_seed_clear.bin


Should Run test-utils.bin
    Run Test                  test-utils.bin


Should Run test-utils_str.bin
    Run Test                  test-utils_str.bin

# Custom tests, with additional run parameters or conditions

Should Run test-fpsensor.bin uart
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fpsensor.bin              uart


Should Run test-fpsensor.bin spi
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fpsensor.bin              spi


Should Run test-debug.bin no_debugger
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-debug.bin                 no_debugger


Should Run test-system_is_locked.bin wp_on
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-system_is_locked.bin      wp_on


Should Run test-system_is_locked.bin wp_off
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Create Machine            system_is_locked
    ${RESET_MACRO}=  Catenate  SEPARATOR=\n
    ...  """
    ...  sysbus LoadBinary $bin 0x08000000
    ...  sysbus LoadSymbolsFrom $elf_ro
    ...  sysbus LoadSymbolsFrom $elf_rw
    ...  gpiob.GPIO_WP Press
    ...  cpu PC 0x8000219
    ...  """
    Execute Command           macro reset${\n}${RESET_MACRO}
    Execute Command           machine Reset
    Start Emulation
    Wait For Line On Uart     Image: RW
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP: The AP is failing to respond despite being powered on.
    Write Line To Uart
    Wait For Prompt On Uart   >
    Write Line To Uart        runtest wp_off
    Wait For Line On Uart     Pass!


Should Run test-rollback.bin region0
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Expect MPU failure        test-rollback.bin              region0


Should Run test-rollback.bin region1
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Expect MPU failure        test-rollback.bin              region1


Should Run test-rollback_entropy.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-rollback_entropy.bin
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!


Should Run test-flash_write_protect.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-flash_write_protect.bin
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!


Should Run test-benchmark.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start To Prompt           test-benchmark.bin
    # Reduce quantum value as this test requires more precision
    Execute Command           emulation SetGlobalQuantum "0.000003"
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!
