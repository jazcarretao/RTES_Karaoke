Karaoke Project
=========================
In the framework of the Real Time Embedded Systems course Final Project at EPFL, Balási and me developed a Karaoke system based on an Altera device which contains an FPGA and an ARM module embedded in the same die. The FPGA modules mix a microphone signal and an audio playback from the computer. The mixed audio signal is played through an audio codec in the Altera device. At the same time, the ARM module reads the lyrics of the desired karaoke song from an SD card connected to the Altera device. The lyrics can be displayed into a screen connected by VGA to the Altera platform. Then, you are ready to start singing.

Contributors
------------
Juan Azcarreta Ortiz, Balási Szabolcs.

Dependencies
------------
* The FPGA cores were developed using Altera's tools (the free web edition should be sufficient).

Software License
----------------

Copyright (c) 2016 EPFL

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
