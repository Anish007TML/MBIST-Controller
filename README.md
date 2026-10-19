# FPGA-Based Memory Built-In Self-Test (MBIST)

A Verilog RTL project that implements a Memory Built-In Self-Test (MBIST) controller for testing a synchronous RAM using a March C−-style test sequence. The project is intended for simulation and FPGA implementation in Xilinx Vivado.

## Project Overview

Memory faults can cause incorrect data storage or retrieval. MBIST adds on-chip test logic that writes test patterns to memory, reads them back, and compares the returned data against the expected values.

This project contains:
- A synchronous RAM model.
- An FSM-based MBIST controller.
- A top-level module connecting the controller and RAM.
- A testbench that runs a normal-memory case and a fault-injected case.
- Simulation waveforms for observing the test sequence and its pass/fail behavior.

> **Note:** This repository documents the modernized RTL implementation used for this project. It is not a drop-in recreation of the original Virtex-II `RAMB16_S36` primitive-based design.

## MBIST Test Algorithm

The controller performs a March C−-style sequence over the memory address range:

1. **Ascending:** write `0` to every address.
2. **Ascending:** read `0`, then write `1`.
3. **Ascending:** read `1`, then write `0`.
4. **Descending:** read `0`, then write `1`.
5. **Descending:** read `1`, then write `0`.
6. **Ascending:** read `0` and verify the final contents.

The controller asserts `done` when the test completes. A mismatch between the expected and observed read data sets the `fail` flag.

## Repository Contents

Expected source layout:

```text
fpga-mbist/
├── README.md
├── .gitignore
├── rtl/
│   ├── mbist_ram.v
│   ├── mbist_controller.v
│   └── mbist_top.v
├── sim/
│   └── tb_mbist.v
└── docs/
    ├── mbist_pass_waveform.png
    └── mbist_fault_waveform.png
