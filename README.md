# AE-Recoil-Pattern-Generation
Prerequisites: 
You need to have a modern version of Adobe After Effects installed, as well as ahk itself, in addition to at least basic level knowledge of AHK scripting.

The patterns made using the old Python pattern generator didn’t quite work for me, so in pursuit of a better method I came up with this:


About the method: 

The idea is to use Adobe After Effects motion tracking feature to track the movement of an object that is static in the firing range, but starts moving on screen when firing because the gun's recoil moves the camera up. After Effects then outputs the opposite of the tracked pattern - meaning the pattern it shows you is the movement you have to do to stabilize the recoil. 

My goal was to define a method that would output a decent to good recoil pattern out of the box without much need to mess with the numbers themselves/

How does the script work from start to finish:

Adobe After effects outputs a big set of absolute coordinates based on your video resolution and framerate - 1080p 60 fps in this case.

The structure is:

line number  X    Y 

The script reads these from the .txt file provided and using some basic math converts them from absolute coordinates to relative offset to your mouse cursor. The rest is identical to other ahk scripts. 

To determine the waiting time between the mouse movements the overall firing time of the weapon gets divided by the amount of lines in the tracked pattern.txt

What is different is the fact that this script doesn’t do one mouse movement per bullet.
