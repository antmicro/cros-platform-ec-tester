*** Test Cases ***
Should Pass Simple Test
    Reset Emulation
    Execute Command           $bin=@${CURDIR}/test-abort.bin
    Execute Command           $elf_ro=@${CURDIR}/abort.RO.elf
    Execute Command           $elf_rw=@${CURDIR}/abort.RW.elf
    Execute Script            ${CURDIR}/bloonchipper.resc
    # Execute Command           logFile $ORIGIN/log.txt
    Create Terminal Tester    sysbus.usart2  timeout=5

    Start Emulation
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP: The AP is failing to respond despite being powered on.
    Write Line To Uart
    Wait For Prompt On Uart   >

    Write Line To Uart        runtest
    Wait For Line On Uart     Pass!

Should Fail Simple Test
    Reset Emulation
    Execute Command           $bin=@${CURDIR}/test-abort.bin
    Execute Command           $elf_ro=@${CURDIR}/abort.RO.elf
    Execute Command           $elf_rw=@${CURDIR}/abort.RW.elf
    Execute Script            ${CURDIR}/bloonchipper.resc
    # Execute Command           logFile $ORIGIN/log.txt
    Create Terminal Tester    sysbus.usart2  timeout=5

    Start Emulation
    Wait For Line On Uart     MKBP not cleared within threshold
    Wait For Line On Uart     MKBP: The AP is failing to respond despite being powered on.
    Write Line To Uart
    Wait For Prompt On Uart   >

    Write Line To Uart        runtest
    Wait For Line On Uart     Fail!
