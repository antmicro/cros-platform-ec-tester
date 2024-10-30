# Custom tests, with additional run parameters or conditions

Should Run test-fp_transport.bin uart
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fp_transport.bin          uart


Should Run test-fp_transport.bin spi
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fp_transport.bin          spi


Should Run test-debug.bin no_debugger
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-debug.bin                 no_debugger


Should Run test-system_is_locked.bin wp_on
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-system_is_locked.bin      wp_on


Should Run test-system_is_locked.bin wp_off
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Create Machine            system_is_locked
    # Disable write protection
    Execute Command           gpioPortB.GPIO_WP Press
    Wait For System Prompt
    Write Line To Uart        runtest wp_off
    Wait For Line On Uart     Pass!


Should Run test-rollback.bin region0
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-rollback.bin              region0  ${MPU_FAILURE_MESSAGE}


Should Run test-rollback.bin region1
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-rollback.bin              region1  ${MPU_FAILURE_MESSAGE}


Should Run test-rollback_entropy.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test In RO            test-rollback_entropy.bin


Should Run test-flash_write_protect.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test In RO            test-flash_write_protect.bin


Should Run test-sbrk.bin
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test In RO            test-sbrk.bin


Should Run test-mpu.bin RW
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-mpu.bin                   message=${MPU_FAILURE_MESSAGE}


Should Run test-mpu.bin RO
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test In RO            test-mpu.bin                   message=${MPU_FAILURE_MESSAGE}
