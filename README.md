# Unsigned Arithmetic Divider Architectures

This repository contains SystemVerilog implementations of three unsigned integer divider architectures:

1. Unsigned Subtractive Divider
2. Unsigned Restoring Divider
3. Unsigned Pipelined Restoring Divider

The objective of this project is to design, simulate, and compare different hardware approaches for unsigned division in digital systems.

---

## Overview

Division is one of the more hardware-expensive arithmetic operations in digital design. This project implements unsigned division using three different architectures, each with different trade-offs in terms of latency, throughput, and hardware cost.

All dividers compute:

```text
Q = floor(Ain / Bin)
R = Ain % Bin
```

where:

* `Ain` is the unsigned dividend
* `Bin` is the unsigned divisor
* `Q` is the quotient
* `R` is the remainder

The default operand width used in this project is:

```systemverilog
`define WIDTH 10
```

---

## Implemented Modules

### 1. Unsigned Subtractive Divider

This divider performs division using repeated subtraction. The divisor is repeatedly subtracted from the dividend until the remaining value is smaller than the divisor.

#### Algorithm

For `Ain / Bin`:

1. Load dividend into an internal register.
2. Repeatedly subtract divisor from the dividend.
3. Increment quotient after every successful subtraction.
4. Stop when the remaining value is less than the divisor.
5. The final remaining value is the remainder.

#### Characteristics

| Feature         | Description                                     |
| --------------- | ----------------------------------------------- |
| Architecture    | Iterative                                       |
| Algorithm       | Repeated subtraction                            |
| Hardware cost   | Low                                             |
| Latency         | Depends on quotient value                       |
| Throughput      | One division at a time                          |
| Best suited for | Simple division logic and small quotient values |

---

### 2. Unsigned Restoring Divider

This divider implements the restoring division algorithm. It performs one division iteration per clock cycle and produces the quotient and remainder after a fixed number of cycles.

#### Algorithm

For each bit of the dividend:

1. Shift the partial remainder left.
2. Bring in the next dividend bit.
3. Subtract the divisor.
4. If the subtraction result is negative, restore the previous partial remainder and set the quotient bit to `0`.
5. Otherwise, keep the subtraction result and set the quotient bit to `1`.

#### Characteristics

| Feature         | Description                                  |
| --------------- | -------------------------------------------- |
| Architecture    | Iterative                                    |
| Algorithm       | Restoring division                           |
| Hardware cost   | Moderate                                     |
| Latency         | Fixed, approximately `WIDTH` cycles          |
| Throughput      | One division at a time                       |
| Best suited for | Predictable latency with lower hardware cost |

---

### 3. Unsigned Pipelined Restoring Divider

This divider implements a fully pipelined version of the restoring division algorithm. Each pipeline stage performs one restoring division iteration.

#### Algorithm

The restoring division operation is split across multiple pipeline stages. For a `WIDTH`-bit divider, the design uses `WIDTH` stages. Each stage performs one partial remainder update and quotient bit decision.

After the pipeline is filled, the divider can produce one result per clock cycle.

#### Characteristics

| Feature         | Description                                    |
| --------------- | ---------------------------------------------- |
| Architecture    | Pipelined                                      |
| Algorithm       | Restoring division                             |
| Hardware cost   | High                                           |
| Latency         | Fixed, `WIDTH` pipeline stages                 |
| Throughput      | One result per clock cycle after pipeline fill |
| Best suited for | High-throughput unsigned division              |

---

## Common Interface

Each divider uses a similar interface:

```systemverilog
input  logic clk
input  logic rst
input  logic inp_valid
input  logic [`WIDTH-1:0] Ain
input  logic [`WIDTH-1:0] Bin

output logic [`WIDTH-1:0] Q
output logic [`WIDTH-1:0] R
output logic busy
output logic out_valid
```

### Signal Description

| Signal      | Direction | Description                          |
| ----------- | --------- | ------------------------------------ |
| `clk`       | Input     | Clock signal                         |
| `rst`       | Input     | Synchronous reset                    |
| `inp_valid` | Input     | Indicates valid input operands       |
| `Ain`       | Input     | Unsigned dividend                    |
| `Bin`       | Input     | Unsigned divisor                     |
| `Q`         | Output    | Quotient                             |
| `R`         | Output    | Remainder                            |
| `busy`      | Output    | Indicates divider is processing data |
| `out_valid` | Output    | Indicates valid output result        |

---

## Design Comparison

| Divider                              | Algorithm                    |                      Latency | Throughput | Hardware Cost |
| ------------------------------------ | ---------------------------- | ---------------------------: | ---------: | ------------- |
| Unsigned Subtractive Divider         | Repeated subtraction         |                     Variable |        Low | Low           |
| Unsigned Restoring Divider           | Restoring division           | Fixed, around `WIDTH` cycles |        Low | Moderate      |
| Unsigned Pipelined Restoring Divider | Pipelined restoring division |        Fixed, `WIDTH` stages |       High | High          |

---

## Testbenches

The repository includes testbenches for verifying the divider modules.

The testbenches apply unsigned input operands and check the generated quotient and remainder values.

---

## Notes

* These dividers support unsigned operands only.
* Signed division is not implemented.
* Division by zero should be handled explicitly if required by the target system.
* The pipelined divider improves throughput but uses more hardware resources than the iterative dividers.
* The subtractive divider has simple hardware but can take many cycles for large quotient values.

---


