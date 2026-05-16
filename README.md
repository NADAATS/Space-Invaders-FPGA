# Space Invaders — FPGA Basys3

Classic Space Invaders game implemented in Verilog on Basys3 FPGA with VGA video output.

## Tech stack
- Verilog HDL
- Basys3 FPGA (Xilinx Artix-7)
- VGA 640x480 display output
- Vivado Design Suite

## Features
- Real-time game logic : player ship, bullets, alien grid
- VGA sync signal generation (horizontal & vertical)
- 7-segment display for score
- Hardware-validated on Basys3 target board

## Project structure
SpaceInvaders_Final/
├── srcs/          # Verilog source files
│   ├── top_game.v
│   ├── vga_sync.v
│   ├── ship_logic.v
│   ├── bullet_logic.v
│   ├── alien_bullet_logic.v
│   └── extrater_grid.v
├── constrs/       # XDC constraints (Basys3 pinout)
└── runs/          # Vivado synthesis & implementation


## Academic context
Master's project — Université Bretagne Sud, Lorient (2025)  
Embedded & Integrated Systems (SESI)
