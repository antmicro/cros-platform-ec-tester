# Custom tests, with additional run parameters or conditions

Should Run test-debug.bin no_debugger
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-debug.bin                 no_debugger


Should Run test-fp_transport.bin uart
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fp_transport.bin          uart


Should Run test-fp_transport.bin spi
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fp_transport.bin          spi


Should Run test-rollback_entropy.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-rollback_entropy.bin
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!


Should Run test-sbrk.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Start In RO               test-sbrk.bin
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!


Should Run test-system_is_locked.bin wp_on
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-system_is_locked.bin      wp_on


Should Run test-system_is_locked.bin wp_off
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-system_is_locked.bin      wp_off


Should Run test-fpsensor_hw.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Create Machine            fpsensor_hw
    # Hardware id of the expected fpsensor
    Execute Command           spip.fpsensor FeedSample 0x00
    Execute Command           spip.fpsensor FeedSample 0x02
    # Last 4 bits are random as this is manufacturing id that should be discarded by the test
    ${manufacturing_id}=      Generate Random String  1  [NUMBERS]ABCDEF
    Execute Command           spip.fpsensor FeedSample 0x1${manufacturing_id}
    Start Emulation
    Wait For System Prompt
    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!
