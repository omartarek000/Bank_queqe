# Queue Module (Verilog)

## Overview

This module implements a **queue (people counter) finite-state machine** using two photocell sensors and a teller count input. It outputs:

* **Pcount** — number of people currently in the queue
* **Pwait** — estimated wait time until service
* **emptyFlag** and **fullFlag** — queue boundary status

This module is designed to be instantiated in a higher-level **Top Module**, along with other system components.

---

## Features

### ✔ FSM-Based People Counter

The design detects **negative edges** from two photocells:

* **phcOne** → person entering the queue
* **phcTwo** → person leaving the queue

Photocells are **active-low**, so falling edges represent events.

### ✔ Built-in Synchronization

Both photocell inputs are passed through **two-stage synchronizers** to prevent metastability.

### ✔ Clean Edge Detection

Previous sampled states allow reliable falling-edge detection for both sensors.

### ✔ Queue Capacity Control

* Queue size defined by parameter `n`
* Maximum count = `(1 << (n+1)) - 1`
* Overflow and underflow protection
* Automatic empty/full flags

### ✔ Wait Time Estimation

Wait time is computed using:

```
numerator = 3 * (Pcount + Tcount - 1)
```

Then scaled based on number of tellers:

* 1 teller → full numerator
* 2 tellers → numerator / 2
* 3 tellers → (numerator * 1) / 3

Parameter `WTIME_WIDTH` is auto-calculated using `$clog2`.

---

## I/O Description

### **Inputs**

| Name     | Width | Description                       |
| -------- | ----- | --------------------------------- |
| `reset`  | 1     | Active-low reset                  |
| `phcOne` | 1     | Photocell (entering), active low  |
| `phcTwo` | 1     | Photocell (leaving), active low   |
| `Tcount` | 2     | Number of tellers (1–3 supported) |
| `clock`  | 1     | System clock                      |

### **Outputs**

| Name        | Width              | Description              |
| ----------- | ------------------ | ------------------------ |
| `Pcount`    | n+1 bits           | Current people count     |
| `Pwait`     | WTIME_WIDTH+1 bits | Estimated wait time      |
| `emptyFlag` | 1                  | HIGH when queue is empty |
| `fullFlag`  | 1                  | HIGH when queue is full  |

---

## Parameters

| Parameter     | Purpose                 | Default                  |
| ------------- | ----------------------- | ------------------------ |
| `n`           | Controls max queue size | 3                        |
| `idle`        | FSM idle state          | 2'b00                    |
| `coming`      | FSM state on enter      | 2'b01                    |
| `leaving`     | FSM state on exit       | 2'b10                    |
| `P_COUNT_MAX` | Maximum people count    | `(1 << (n+1)) - 1`       |
| `P_WAIT_MAX`  | Upper wait time bound   | `3 * P_COUNT_MAX`        |
| `WTIME_WIDTH` | Bit width of wait time  | `$clog2(P_WAIT_MAX + 1)` |

---

## FSM Description

The state machine has three states:

* **idle** — No movement
* **coming** — A person enters the queue
* **leaving** — A person leaves the queue

State transitions are solely based on falling edges from the photocells.

---

## Internal Logic Breakdown

### 1. **Synchronization Block**

Ensures clean, stable inputs using two flip‑flops per photocell.

### 2. **Edge Detection**

Compares the current synchronized level with the previous value to detect falling edges.

### 3. **FSM Next-State Logic**

Determines upcoming state based on detected events.

### 4. **FSM State Register**

Updates state on each clock edge.

### 5. **Queue Counter**

Increments or decrements `Pcount` based on the active FSM state.

### 6. **Wait Time Calculator**

Computes expected waiting time using simple arithmetic.

---

## Integration Notes for Top Module

* The photocell inputs should be **debounced** or connected directly to IR break-beam sensors.
* Ensure `Tcount` is valid (1–3).
* Clock and reset must be global and clean.
* This module may be instantiated as one part of a multi-module system.

---

## Example Instantiation

```verilog
queue #(
    .n(3)
) queue_inst (
    .reset(reset),
    .phcOne(phcOne),
    .phcTwo(phcTwo),
    .Tcount(Tcount),
    .clock(clock),
    .Pcount(Pcount),
    .Pwait(Pwait),
    .emptyFlag(emptyFlag),
    .fullFlag(fullFlag)
);
```

---

## Authors

- Khaled
- Omar
- Mahmoud

---
