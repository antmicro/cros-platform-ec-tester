# Custom tests, with additional run parameters or conditions

Should Run test-fpsensor.bin uart
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fpsensor.bin              uart


Should Run test-fpsensor.bin spi
    Set Test Variable         ${TESTS_PATH}                  ${TESTS_PATH}/custom
    Run Test                  test-fpsensor.bin              spi
