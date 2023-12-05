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
    ...  gpioPortB.GPIO_WP Press
    ...  cpu PC 0x80002ed
    ...  """
    Execute Command           macro reset${\n}${RESET_MACRO}
    Execute Command           machine Reset
    Start Emulation
    Wait For System Prompt
    Write Line To Uart        runtest wp_off
    Wait For Line On Uart     Pass!


Should Run test-flash_write_protect.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-flash_write_protect.bin
    Write Line To Uart        runtest
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

Should Run test-benchmark.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start To Prompt           test-benchmark.bin
    # Reduce quantum value as this test requires more precision
    Execute Command           emulation SetGlobalQuantum "0.000005"
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!

Should Run test-fpsensor_hw.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Create Machine            fpsensor_hw
    # Hardware id of the expected fpsensor
    Execute Command           spi4.fpsensor FeedSample 0x00
    Execute Command           spi4.fpsensor FeedSample 0x14
    # Last 4 bits are random as this is manufacturing id that should be discarded by the test
    ${manufacturing_id}=      Generate Random String  1  [NUMBERS]ABCDEF
    Execute Command           spi4.fpsensor FeedSample 0x0${manufacturing_id}
    Start Emulation
    Wait For System Prompt
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!

Should Run test-sbrk.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-sbrk.bin
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!
