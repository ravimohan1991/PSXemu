## PSXemu - Playstation emulator in C++

----

PSXemu is a experimental emulator project for the Playstation 1. It aims to be an easy to use and well-documented emulator. Currently you can compile this multiplatform software and run on Linux and MacOS.
The first aim is to boot from BIOS.

## Features
- A full implementation of the MIPS R3000A CPU.
- Partial GPU implementation with texturing.
- Working DMA routines.
- Software rasterizer for accurate rendering.

## Goals
- Create a JIT recompiler in the future.
- Complete the GPU (support for line primitives).
- Boot the first game.
- Create an easy to use GUI.
