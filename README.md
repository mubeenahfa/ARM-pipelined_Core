# ARM Pipelined Core

This repository contains the implementation of a 32-bit 5-stage pipelined soft core. The processor is designed to execute a subset of ARM instructions and is implemented in Verilog HDL. The project includes the design of the datapath, control unit, hazard unit, however, the testbench I used to verify my designs was built by someone else and has not been included in the repository. I have included a screenshot of the testbench results instead.
## Table of Contents

- [Objectives](#objectives)
- [Instruction Set Architecture (ISA)](#instruction-set-architecture-isa)
- [Design Details](#design-details)
  - [Datapath Design](#datapath-design)
  - [Controller Design](#controller-design)
  - [Hazard Unit](#hazard-unit)
- [Experimental Work](#experimental-work)



## Objectives

The primary objectives of this project were to:
- Design a 32-bit pipelined processor.
- Construct a datapath and control unit for the processor.
- Implement the processor on the DE1-SoC FPGA board.
- Execute a subset of ARM instructions as specified in the instruction set.

## Instruction Set Architecture (ISA)

The processor supports the following ARM instructions:

| Mnemonic | Name             | Operation                                     |
|----------|------------------|-----------------------------------------------|
| ADD      | Addition         | `add Rd,Rn,Rm` Rd← Rn + (Rm sh shamt5)        |
| SUB      | Subtraction      | `sub Rd,Rn,Rm` Rd← Rn - (Rm sh shamt5)        |
| AND      | Bitwise And      | `and Rd,Rn,Rm` Rd← Rn & (Rm sh shamt5)        |
| ORR      | Bitwise Or       | `orr Rd,Rn,Rm` Rd← Rn | (Rm sh shamt5)        |
| MOV      | Move to Register | `mov Rd,Rm` Rd← (Rm sh shamt5)                |
| MOV      | Move to Register | `mov Rd,rot-imm8` Rd← (imm8 rr rot<< 1)       |
| CMP      | Compare          | `cmp Rd,Rn,Rm` set the flag if (Rn - Rm =0)   |
| STR      | Store            | `str Rd,[Rn,imm12]` Mem[Rn + imm12] ← Rd      |
| LDR      | Load             | `ldr Rd,[Rn,imm12]` Rd ← Mem[Rn + imm12]      |
| B        | Branch           | `b imm24` PC ← (PC + 8) + (imm24<< 2)         |
| BL       | Branch with Link | `bl imm24` PC ← (PC + 8) + (imm24<< 2), R14 ← PC + 4 |
| BX       | Branch and Exchange | `bx Rm` PC ← Rm                         |

## Design Details

### Datapath Design

The datapath is designed to support the ARM ISA with five stages: Fetch, Decode, Execute, Memory, and Writeback. The components used in the datapath include:
- Instruction Memory
- Data Memory
- Register File
- Program Counter
- ALU
- Immediate Extender
- Multiplexers
- Combinational Shifter
- Interim Registers for Pipelined Operation
- Adders

### Controller Design

The controller is designed to generate control signals for the datapath components and handle various instructions, including BL and BX, with additional control signals. A RESET signal is included to initialize the processor.

### Hazard Unit

The hazard unit is implemented to handle data and control hazards:
- **Data Hazards**: Handled by forwarding and minimal stalling.
- **Control Hazards**: Handled by forwarding the new PC value and flushing incorrect stages.


## Experimental Work

The processor design is uploaded to the DE1-SoC FPGA board. The top-level file connects the processor to the board's buttons, switches, and seven-segment displays for debugging and demonstration purposes.


