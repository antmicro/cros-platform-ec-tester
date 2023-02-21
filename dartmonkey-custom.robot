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


Should Run test-debug.bin debugger
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-debug.bin                 debugger


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
    Wait For Line On Uart     Image: RW
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP not cleared within threshold
    Write Line To Uart
    Wait For Prompt On Uart   >
    Write Line To Uart        runtest wp_off
    Wait For Line On Uart     Pass!


Should Run test-flash_write_protect.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-flash_write_protect.bin
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!


Should Run test-rollback.bin region0
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-rollback.bin              region0


Should Run test-rollback.bin region1
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-rollback.bin              region1


Should Run test-rollback_entropy.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-rollback_entropy.bin
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!
