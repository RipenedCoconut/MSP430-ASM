# MSP430-ASM
Texas Instruments MSP430 Assembly Experiments

The projects contained within the root of this repo are some experiements I've performed with the Texas Instruments MSP430 microcontroller written in TI assembly. I use two different TI Launchpads with the MSP430FR6989 chip and the MSP430FR4133 chip. The FR6989 has 128KB of FRAM and is the target of most of these projects unless otherwise stated (the MSP430FR4133 only has 16KB of FRAM).

## Usage
 To use these programs, download the latest release zip file. Open CCStudio 12 and import the _"project".zip_ file to your workspace as a CCS Project. You can then flash or debug the main.asm file.
 
## Projects

**Blinky**

The Blinky program uses hardware interrupts and buttons exposed on the MSP430's _port 1_. These buttons trigger LED lights on _port 1_ (red LED on TI launchpad) and _port 9_ (green LED on TI launchpad).

--------------------------

**PatternGame**

A simple program that operates as a pseudo "Simon" style game. After displayling a light, the user must click the corresponding button to score a point. If the user presses incorrectly, the game resets.
