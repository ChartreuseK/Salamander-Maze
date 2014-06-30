# Salamander Escape the Maze

A 2nd year class assignment at the University of Calgary in computing machinery that I enjoyed enough to go above and beyond the original specifications. This is a **bare-metal** ARM assembly game for the Raspberry Pi. 

It is a simple tile based maze game where you collect keys to open doors and to reach the exit. Each level has a maximum number of actions (moving and opening doors) that you can take to complete the maze. The game has 6 mazes that the player can "challenge" themselves to complete.

All sprites in the game simple 16x16 tiles upscaled to 32x32 using my graphics "engine", the sprites were drawn in GIMP and exported using the C-source file option saving as 565 colour, and modified to go straight into ARM assembly. The font used is a simple 8x8 (well 7x7 if you don't count the whitespace on the right and bottom) font that I designed by typing out the binary bits as a comment and translating that to hex.

## Prerequisites 

1. Raspberry Pi and Power Cable(I think that's a given)
2. SD Card 
3. Screen that can display a 1024x768x16 video signal
4. HDMI (or HDMI to DVI) cable (Untested but it *may* work over composite)
5. SNES Controller (and someway of hooking it's pins up to the Pi)
6. arm-none-eabi cross compiler toolkit

## Setup

1. The SD card needs to setup with a FAT partition containing the files nessisary to boot the pi, an easy (but bandwidth intensive and requires a 4GB+ card) way is to use the NOOBS installer image on the pi (http://www.raspberrypi.org/documentation/installation/installing-images/README.md) and get it to setup the boot partition. A much smaller way is to grab the files from https://github.com/raspberrypi/firmware/tree/master/boot and put them on the root directory of a FAT formated SD card
2. Run **make**
3. Copy the generated **kernel.img** file to the SD card replacing the existing kernel.img
4. Connect the SNES controller to the pi.
* Latch to pin 9
* Data to pin 10
* Clock to pin 11
* Power to 3.3v (Yes the SNES controller is 5v logic but it **will** run at 3.3v to simplify interfacing)
* Ground
5. Plug the SD card and HDMI cables into the Pi
6. Power it up




# Author

* Hayden Kroepfl
  * Github (This one) -  [ChartreuseK](https://github.com/ChartreuseK)
  * Email - hkroepfl@ucalgary.ca


