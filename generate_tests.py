#!/usr/bin/env python3

import os
import shutil

template_file = "template.robot"


def generate_tests(board, uart, timeout):
    with open(template_file, "r") as file:
        template = file.read()

    tests_dir = f"{board}/tests"
    os.makedirs(tests_dir, exist_ok=True)

    if os.path.exists("tests.yml"):
        os.remove("tests.yml")

    with open("tests.yml", "x") as tests_file:

        bins_dir = f"{board}/test-bins"
        for test_suite in os.listdir(bins_dir):

            robot_test_text = (
                template.replace("%UART%", uart)
                .replace("%TIMEOUT%", str(timeout))
                .replace("%TEST_NAME%", test_suite)
            )

            robot_test_file_path = f"{tests_dir}/{test_suite}.robot"
            with open(robot_test_file_path, "w") as target_file:
                target_file.write(robot_test_text)

            tests_file.write(f"- {robot_test_file_path}\n")


def copy_artifacts(board):
    bins_dir = f"{board}/test-bins"

    if os.path.exists(bins_dir):
        shutil.rmtree(bins_dir)

    os.makedirs(bins_dir, exist_ok=True)

    shutil.copytree(f"artifacts/{board}", bins_dir, dirs_exist_ok=True)


if __name__ == "__main__":
    copy_artifacts("sanok")
    generate_tests("sanok", "uart0", "0.1")
