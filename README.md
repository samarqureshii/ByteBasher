# ByteBasher
Our digital take on the classic "Whac-A-Mole" game that uses hand proximity detected by a series of ultrasonic distance sensors on an MCU to register hits on a VGA screen, with a De1-SoC FPGA board manading the increasing game difficulty and score updates.

## ~~Scuffed~~ Timeline
~~No way we pull this off~~
### Uncertainties
- ~~How did they use 5V digital output to the 3.3V FPGA??????~~
- External memory?
- ~~Cannot do 3 by 3 grid- requires 4 bits of the enable GPIO signal + 12 trig/echo pins~~
### Nov 28
- ~~Ultrasonic sensors reading and LED indicators for which "grid square" is being hit in binary(Samar)~~
- Control mostly coded (Samar)
- Datapath mostly coded (Annie)
- ~~LFSR randomization algorithm (Samar)~~
- ~~Dual display counter (Samar)~~
### Nov 29
- Test ultrasonic with GPIO pins and pray nothing goes electroboom (Samar)
- Audio coded
    - Audio RAM
    - Audio Controller
    - `avc`?
- VGA mostly coded (Annie)
- Look into SDRAM

### Nov 30 

All nighter in the lab

- 
### Nov 1
### Nov 2
### Nov 3
### Nov 4
All nighter in the lab
### Nov 5
Everything needs to be working at this point, final tweaks in the morning