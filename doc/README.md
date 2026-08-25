# GRISC documentation

This directory contains the documentation for [GRISC](https://github.com/mgm8/grisc), a synthesizable VHDL implementation of a five-stage, 32-bit RISC-V processor. The processor implements the RV32I base integer ISA and the RV32M multiplication and division extension (RV32IM), with forwarding and data-hazard detection.

## Prerequisites

To build the Sphinx site, install Python 3 and the documentation dependencies:

```sh
python3 -m pip install -r requirements.txt
```

To build the PDF technical report, also install a LaTeX distribution that includes `latexmk`.

## Build the Sphinx documentation

From this directory, run:

```sh
make html
```

The generated site is written to `_build/html/index.html`. To see the other available builders and Make targets, run `make help`.

Clean generated Sphinx files with:

```sh
make clean
```

## License

This documentation is licensed under the [Creative Commons Attribution-ShareAlike 4.0 International License](LICENSE).
