# CrOS EC Tester

Copyright (c) 2020-2023 [Antmicro](https://www.antmicro.com)

EC Tester presents the testing workflow for [ChromiumOS Embedded Controller software](https://chromium.googlesource.com/chromiumos/platform/ec/).
It uses GitHub Actions for handling the execution and [Renode](https://renode.io) for testing.

Based on precompiled EC binaries and tests, Renode runs each available binary, waits for the system image to load, and issues the `runtest` command with required arguments.

After that, we await the `Pass!` string to be printed out.

These tests verify the `bloonchipper` and `dartmonkey` targets.

## Renode documentation

Please go to [docs.renode.io](https://docs.renode.io/) for documentation on Renode usage.

## How to use this repository?

### Preparing the repository

Before using the repository you first have to prepare it by downloading precompiled EC test binaries.
This repository provides nightly builds of all tests for the `bloonchipper` and `dartmonkey` targets using GitHub Actions.

To download them first navigate to the [Actions](https://github.com/antmicro/cros-platform-ec-tester/actions) tab then click on the top-most run.
There will be a `Artifacts` box on the bottom of the page, there click on `test-binaries` this will start a download of a zip file with all prebuilt binaries required to run the tests.

The contents of the archive need to be unpacked into a directory called `artifacts` that should be created in the root of the repository.

After those files are in place you need to run a Python script - `generate_tests.py` to generate a `*.robot` file with tests for each platform and `tests.yml`, that can be used to run all tests for all platforms. 
After running the script test binaries will be copied to appropriate locations and the `artifacts` directory can be removed.

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
- [template.robot](template.robot) - template used by `generate_tests.py`.
- [custom_tests.yml](custom_tests.yml) - list of tests that require special handling for each target.
In particular tests can be in the following category:
    - `custom` - test requires a custom definition.
    Those definitions are placed in the `*-custom.robot` file for the appropriate board.
    - `skip` - tests from this category are not run due to some issues, for example peripherals required by the test are not yet supported in Renode.
- [bloonchipper/](bloonchipper) - directory containing the main `ec.bin` build, along with `ec.RO.elf` and `ec.RW.elf`. The ELF files are used to provide symbol names. After running `generate_tests.py` test binaries will also be placed in this directory.

Similar structure is created for [dartmonkey/](dartmonkey).
