# CrOS EC Tester

Copyright (c) 2020-2022 [Antmicro](https://www.antmicro.com)

EC Tester presents the testing workflow for [ChromiumOS Embedded Controller software](https://chromium.googlesource.com/chromiumos/platform/ec/).
It uses GitHub Actions for handling the execution and [Renode](https://renode.io) for testing.

Based on precompiled EC binaries and tests, Renode runs each available binary, waits for the `RW` image to load, and issues the `runtest` command.

After that, we await the `Pass!` string to be printed out.

These tests verify the `bloonchipper` and `dartmonkey` targets.

## Renode documentation

Please go to [docs.renode.io](https://docs.renode.io/) for documentation on Renode usage.

## How to use this repository?

### Renode-run

The simplest but least flexible way of running these tests requires you to work on Linux and have Python3 and pip installed:

```
$ pip3 install --user git+https://github.com/antmicro/renode-run
$ renode-run test -- -t tests.yml
```

You can run Renode interactively simply using:

```
$ renode-run
```

### Portable package

Go to [https://builds.renode.io/](https://builds.renode.io/) and look for the `renode-latest.*` package that matches your operating system.

For Linux, the [Linux Portable package](https://dl.antmicro.com/projects/renode/builds/renode-latest.linux-portable.tar.gz) is preferred.

After you unpack or install the package, ensure that it's available in your `$PATH` and run tests using:

```
$ renode-test -t tests.yml
```

or run Renode interactively using:

```
$ renode
```

### Interactive usage

When starting Renode interactively, you can load a script you want with the `include` command (replace `bloonchipper` with `dartmonkey` if needed):

```
(monitor) include @bloonchipper.resc
(monitor) start
```

Both `include` and `start` commands can be abbreviated to `i` and `s`, respectively.

To provide your own binaries, you have to overwrite three variables, one for the binary itself and 2 for ELF files with symbols:

```
(monitor) $bin=@path/to/your.bin
(monitor) $elf_ro=@path/to/your.RO.elf
(monitor) $elf_rw=@path/to/your.RW.elf
(monitor) i @bloonchipper.resc
```

## Repository structure

The repository consists of the following elements:

- [stm32f412.repl](stm32f412.repl), [stm32h743.repl](stm32h743.repl) - platform files for, respectively, bloonchipper and dartmonkey.
- [bloonchipper.resc](bloonchipper.resc), [dartmonkey.resc](dartmonkey.resc) - script files to load in Renode, defining the simulation environment.
- [generate_tests.py](generate_tests.py) - script creating `*.robot` test suites based on available test binaries. It also generates `tests.yml` listing all test suites to run in a single Renode call.
- [bloonchipper.robot](bloonchipper.robot), [dartmonkey.robot](dartmonkey.robot) - test files generated by `generate_tests.py`, listing all test cases.
- [tests.yml](tests.yml) - list of available test suites, generated by `generate_tests.py`.
- [template.robot](template.robot) - template used by `generate_tests.py`.
- [bloonchipper/](bloonchipper) - directory containing the main `ec.bin` build, along with `ec.RO.elf` and `ec.RW.elf`. The ELF files are used to provide symbol names.
- [bloonchipper/tests](bloonchipper/tests) - directory with test cases verified with `bloonchipper.robot`. Both `*.bin` and `*.elf` files are provided.
- [bloonchipper/tests/skip](bloonchipper/tests/skip) - directory with skipped tests that cause Renode to hang. These tests can be considered as failing.

Similar structure is created for [dartmonkey/](dartmonkey).
