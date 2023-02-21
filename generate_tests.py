#!/usr/bin/env python3

import os
template_file="template.robot"
test_template="""
Should Run %TEST%
    Run Test                  %TEST%

"""
test_prefix = "test-"

def generate_tests(board, uart, timeout):
    with open(template_file, "r") as file:
        text = file.read()

    text = text.replace("%PLATFORM%", board).replace("%USART%", uart).replace("%TIMEOUT%", str(timeout))

    with open(board + ".robot", "w") as target_file:
        target_file.write(text)

        tests = []
        for entry in os.scandir(board + "/tests"):
            if entry.is_file() and entry.name.startswith(test_prefix):
                tests.append((entry.name, test_template.replace("%TEST%", entry.name)))

        tests.sort(key=lambda x: x[0])
        for entry in tests:
            target_file.write(entry[1])

        with open(board + "-custom.robot", "r") as custom_tests:
            text = custom_tests.read()

        target_file.write(text)



with open("tests.yml", "w") as tests:
    for board, (uart, timeout) in { 'dartmonkey': ("usart1", 5), 'bloonchipper': ("usart2", 5) }.items():
        generate_tests(board, uart, timeout)
        tests.write(f"- {board}.robot\n")
