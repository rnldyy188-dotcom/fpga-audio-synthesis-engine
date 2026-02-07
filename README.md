# FPGA Audio Synthesis Engine

FPGA-based interactive audio synthesis engine supporting live note generation, arpeggio scheduling, and compressed music playback using BRAM-backed storage.

## Overview

This project was developed as a personal exploration of modular digital system design using Verilog, combining memory architecture, real-time scheduling, and hardware audio waveform generation on FPGA.


Feel free to click  [Project Documentation](https://drive.google.com/file/d/1p9X78ksMyv_qv-GCmge03e0l99LAq_xT/view?usp=sharing) to watch video documentation and guide.


## Hardware Platform

- **FPGA Board:** Digilent Basys-3  
- **FPGA Device:** Xilinx Artix-7 (XC7A35T)  
- **System Clock:** 100 MHz  
- **Audio Output:** PWM-driven passive buzzer  
- **User Inputs:** On-board switches and buttons  

## Software Toolchain

The project includes a Python-based preprocessing tool that converts MIDI files into FPGA-compatible playback memory.

### MIDI Conversion Script
- Parses MIDI timing and tempo events  
- Extracts melody using highest-note selection strategy  
- Applies Run-Length Encoding (RLE) compression  
- Converts MIDI note numbers into hardware frequency dividers  
- Outputs BRAM-ready `.mem` files for playback controller  

**Dependencies**
- Python 3.x  
- `mido` library  

## Features

### Live Note Generation
- Real-time note generation from hardware switch inputs  
- Low-latency square-wave tone synthesis  
- Frequency divider-based waveform generation  

### Arpeggio Scheduling
- Round-robin multi-key scheduling  
- Time-sliced playback for simultaneous key presses  
- Adjustable scheduling resolution  

### BRAM-backed Compressed Recording
- Run-Length Encoding (RLE) compression for recorded note streams  
- Efficient FPGA Block RAM utilization  
- Reduced storage requirements for recorded sequences  

### Playback Engine
- Restartable playback controller  
- Looping playback support  
- FSM-based playback scheduling  

### Song Playback Mode
- ROM-based preloaded song playback  
- Encoded note duration and frequency format  
- Supports rest notes and end-of-sequence commands  
- Compatible with MIDI-to-memory conversion pipeline  

### Envelope Shaping
- Attack and Release envelope control  
- Smooth audio transitions  
- Reduced clicking artifacts during note changes  
