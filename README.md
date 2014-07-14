3D-scanner
==========

Cheap 3D scanner based on Arduino and Processing

I used the base project seen on http://www.instructables.com/id/Lets-cook-3D-scanner-based-on-Arduino-and-Proces/?&sort=ACTIVE&limit=40&offset=40#DISCUSS

If you want to use these programs, you will need the Arduino IDE (for compiling and uploading), and an Arduino Uno compatible devel board for the hardware.
For the Processing program, you will need the Arduino up and running to execute the 3d-scanner. I set up the line_processor as a stand-alone. Just dump the sample images with the program and run it in Processing. It doesnt display content, but it does generate line drawings for each image, and generates a pointcloud file that MeshLab can read.



Changes:

Cleaned up variable names
Configured my stepper.
Set up a ping/pong system so the Processing program knows when a step increment is done. We do this for non-jerky pictures.
Created a separate Processing program to handle image->pointcloud handling. This sped up dev time.
Added a variable to account for vertical placement of camera. Original project assumes a 0 degree inclination respect to platter. Mine is at an angle.

Todo:

Correct math for angled camera placement
Better project box enclosure
Implementation of 2 line lasers I bought for $2.50 each on ebay
Find better camera than my Sony PS2 Eyetoy.
Use Makerbot Digitizer technique of dual line lasers at x degrees from camera and -x degrees from camera and do a dual sweep.
Make Processing programs Usable.

Pie in the sky Todo:

Camera calibration code, including lens calibration
Possibly implement 2 cameras, with one at 0deg and other at 45deg.
Laser calibration code
Table Calibration code
Use PCL library to output pointcloud OR STL
