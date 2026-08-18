<h1 align="center">
    GRISC
    <br>
</h1>

<h4 align="center">Another RISC-V processor written in VHDL.</h4>

<p align="center">
    <a href="https://github.com/mgm8/spacelab#versioning">
        <img src="https://img.shields.io/badge/status-in%20development-red?style=for-the-badge">
    </a>
    <a href="https://github.com/mgm8/grisc/releases">
        <img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/mgm8/grisc?style=for-the-badge">
    </a>
    <a href="https://github.com/mgm8/grisc/releases">
        <img alt="GitHub commits since latest release (by date)" src="https://img.shields.io/github/commits-since/mgm8/grisc/latest?style=for-the-badge">
    </a>
    <a href="https://github.com/mgm8/grisc/commits/main">
        <img alt="GitHub last commit" src="https://img.shields.io/github/last-commit/mgm8/grisc?style=for-the-badge">
    </a>
    <a href="https://github.com/mgm8/grisc/issues">
        <img alt="GitHub issues" src="https://img.shields.io/github/issues/mgm8/grisc?style=for-the-badge">
    </a>
    <a href="https://github.com/mgm8/grisc/graphs/contributors">
        <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/mgm8/grisc?color=yellow&style=for-the-badge">
    </a>
</p>

<p align="center">
    <a href="#overview">Overview</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#repository-layout">Repository layout</a> •
    <a href="#requirements">Requirements</a> •
    <a href="#simulating">Simulating</a> •
    <a href="#license">License</a>
</p>

## Overview

GRISC is an in-development, 32-bit RISC-V processor implemented in VHDL. It is a pipelined core with instruction and data memories, a register file, forwarding, and hazard detection logic. The project includes component-level and core-level GHDL testbenches.

![GRISC block diagram](doc/img/block-diagram.png)

## Architecture

- 32-bit data path and 32-bit memory addresses.
- Five pipeline stages, separated by IF/ID, ID/EX, EX/MEM, and MEM/WB registers.
- RISC-V RV32I-style integer instruction decoding, including control-flow, load/store, immediate, and register-register operations.
- RV32M arithmetic operations: multiply, divide, and remainder variants.
- Data-hazard handling through forwarding and stalling logic.
- Configurable instruction-memory size, data-memory size, and program image. The default core configuration uses a 1 KiB instruction memory and 8 KiB data memory.

The main core is [`hdl/core.vhd`](hdl/core.vhd). Shared instruction and control definitions are in [`hdl/grisc.vhd`](hdl/grisc.vhd), and the top-level testbench is [`hdl/tb/tb_core.vhd`](hdl/tb/tb_core.vhd).

## Repository layout

- [`hdl/`](hdl/) — processor RTL and reusable hardware blocks.
- [`hdl/tb/`](hdl/tb/) — GHDL testbenches, program images, and the test Makefile.
- [`doc/`](doc/) — project documentation.

## Requirements

- [GHDL](https://ghdl.github.io/ghdl/) with VHDL-2008 support.
- GNU Make (to use the supplied test targets).

## Simulating

Run the full set of available testbench targets:

```sh
cd hdl/tb
make
```

Run only the processor-core testbench:

```sh
cd hdl/tb
make core
```

Each target analyzes, elaborates, and runs the selected design with GHDL. Simulation waveforms are written as `.vcd` files in `hdl/tb/`; they can be viewed with a compatible waveform viewer. Set `STOP_TIME` to adjust the stop time for targets that use the common setting:

```sh
make STOP_TIME=1us
```

The core testbench loads [`hdl/tb/program.hex`](hdl/tb/program.hex). To simulate another program, provide a compatible hexadecimal image and update the `PROGRAM_FILE` generic in the testbench or in your own top-level design.

## License

GRISC is licensed under the [Solderpad Hardware License, Version 2.1](LICENSE). The license permits using the project under the Apache License 2.0 terms as described in the license text.
