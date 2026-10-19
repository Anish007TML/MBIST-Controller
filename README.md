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

## Tools and Requirements

- Xilinx Vivado
- Verilog HDL
- Vivado behavioral simulator (XSim)

## How to Run in Vivado

1. Open Xilinx Vivado and create a new RTL project.
2. Add `mbist_ram.v`, `mbist_controller.v`, and `mbist_top.v` as Design Sources.
3. Add `tb_mbist.v` as a Simulation Source.
4. Set `tb_mbist` as the simulation top module.
5. Select **Run Simulation → Run Behavioral Simulation**.
6. Run the testbench until the MBIST test completes.
7. Add the relevant signals to the waveform window and inspect the controller state, RAM address, read/write controls, and data signals.

## Expected Simulation Results

The testbench evaluates two memory instances:

- **Fault-free memory:** The MBIST test should complete with `done = 1` and `fail = 0`.
- **Fault-injected memory:** The MBIST test should detect the injected fault and complete with `done = 1` and `fail = 1`.

The `done` signal may be a one-cycle pulse. Check the RTL and testbench timing when interpreting the results.

## Fault Model

The testbench includes a simple memory fault-injection mechanism to demonstrate MBIST fault detection. For example, a selected memory location may be modified so that a written bit does not retain its expected value.

This is a demonstration model and does not represent every possible memory fault, such as all stuck-at, transition, coupling, or address-decoder faults. The RAM model and timing must be validated for the target FPGA memory architecture before hardware deployment.

## Simulation Waveforms

<img width="2418" height="1366" alt="image" src="https://github.com/user-attachments/assets/fc42b232-2240-4513-aa4b-2db06bf16137" />

## Limitations and Future Work

- The current fault model covers only a limited fault scenario.
- The RAM model should be adapted and verified for the target FPGA family and memory configuration.
- Future improvements may include additional March algorithms, more fault models, fault diagnosis, and FPGA synthesis/resource validation.
