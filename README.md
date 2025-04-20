# MSP430-ASM
Texas Instruments MSP430 Assembly Experiments

The projects contained within the root of this repo are some experiements I've performed with the Texas Instruments MSP430 microcontroller written in TI assembly. I use two different TI Launchpads with the MSP430FR6989 chip and the MSP430FR4333 chip. The FR6989 has 128KB of FRAM and is the target of most of these projects unless otherwise stated (the MSP430FR4333 only has 16KB of FRAM).

**Blinky**
The Blinky program uses hardware interrupts and buttons exposed on the MSP430's _port 1_. These buttons trigger LED lights on port 1 (red LED on TI launchpad) and port 9 (green LED on TI launchpad).
