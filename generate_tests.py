#!/usr/bin/env python3

import os
import yaml
import shutil

custom_test_file = "custom_tests.yml"

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

def copy_artifacts(board):
    tests_dir = f"{board}/tests"
    custom_dir = f"{board}/tests/custom"
    skip_dir = f"{board}/tests/skip"

    if os.path.exists(tests_dir):
        shutil.rmtree(tests_dir)

    os.makedirs(tests_dir, exist_ok=True)
    os.makedirs(custom_dir, exist_ok=True)
    os.makedirs(skip_dir, exist_ok=True)

    for artifact in os.listdir(f"artifacts/{board}"):
        shutil.copy(f"artifacts/{board}/{artifact}", tests_dir)

    with open(custom_test_file, "r") as file:
        board_tests = yaml.safe_load(file)[board]
    
    if "skip" in board_tests:
        for skip in board_tests["skip"]:
            shutil.move(f"{tests_dir}/test-{skip}.bin", skip_dir)
            shutil.move(f"{tests_dir}/{skip}.RO.elf", skip_dir)
            shutil.move(f"{tests_dir}/{skip}.RW.elf", skip_dir)

    if "custom" in board_tests:
        for custom in board_tests["custom"]:
            shutil.move(f"{tests_dir}/test-{custom}.bin", custom_dir)
            shutil.move(f"{tests_dir}/{custom}.RO.elf", custom_dir)
            shutil.move(f"{tests_dir}/{custom}.RW.elf", custom_dir)


with open("tests.yml", "w") as tests:
    for board, (uart, timeout) in { 'dartmonkey': ("usart1", 15), 'bloonchipper': ("usart2", 15) }.items():
        copy_artifacts(board)
        generate_tests(board, uart, timeout)
        tests.write(f"- {board}.robot\n")
