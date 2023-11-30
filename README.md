# ByteBasher
Our digital take on the classic "Whac-A-Mole" game that uses hand proximity detected by a series of ultrasonic distance sensors on an MCU to register hits on a VGA screen, with a De1-SoC FPGA board manading the increasing game difficulty and score updates.

## ~~Scuffed~~ Timeline
~~No way we pull this off~~
### De1-SoC Master Population List:
- HEX0, HEX1 (dual place counter)
- HEX5 (LFSR testing)
- LEDR [9:0] (binary enable signal from GPIO)
- GPIO1[0], GPIO[1], GPIO[2] (binary read from `digitalWrite` output)
### Nov 28
- ~~Ultrasonic sensors reading and LED indicators for which "grid square" is being hit in binary(Samar)~~
- Control mostly coded (Samar)
- Datapath mostly coded (Annie)
- ~~LFSR randomization algorithm coded(Samar)~~
- ~~Dual display counter coded (Samar)~~
### Nov 29
- ~~Test ultrasonic with GPIO pins and pray nothing goes electroboom (Samar)~~
- Test LFSR (Samar)
- ~~Test counter (Samar/Annie)~~
- Audio coded (Samar)
    - Audio RAM
    - Audio Controller
    - `avc`?
    - Do we need a separate FSM for audio? 
- VGA mostly coded (Annie)
- Finalize Datapath code (Samar/Annie)
- Finalize Control code (Samar/Annie)
- ~~Test `.mif` file on VGA (Annie)~~
- Look into double buffering (Samar)
- Look into SDRAM (Samar)

### Nov 30 
All nighter in lab
- Test VGA with Datapath and Control 
### Nov 1
### Nov 2 (Saturday)
- Arrive in lab 8am 
### Nov 3 (Sunday)
- Arrive in lab 8am
### Nov 4
All nighter in lab
- Film demo video 

### Nov 5
5pm demo time 