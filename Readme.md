# ABTO Tools for 3ds Max

## Summary

This script gives some small tools for UV mapping in 3ds max

* Welding UV vertices

![Screenshot](/readmeimages/screenshot.png)
	
## Contents:

1. Author
2. Features
3. Installation
4. Version History

## 1. Author

Made by Dmitry Maslov @ http://maslov.co
* Skype: blitz3dproger
* Telegram: @ABTOMAT
* GitHub: ABTOMAT

Feel free to let me know your opinion.
Constructive feedback is appreciated.

January 2018.

## 2. Features

### Welding UV vertices

(click on the image below to see the video)

[![Welding UV video](https://img.youtube.com/vi/pljZN8-Nex8/0.jpg)](https://www.youtube.com/watch?v=pljZN8-Nex8)

You can weld UV vertices within the given threshold by clicking "Weld" button.

![Before welding](/readmeimages/welding_regular_before.png)
![After welding](/readmeimages/welding_regular_after.png)

You can also do this only by U or by V coordinate by choosing the corresponding radiobutton.


## 3. Installation

* Drag and drop the *.mcr file from Windows Explorer to the 3ds Max window.
* Select menu item "Customize -> Customize User Interface..."
* Switch to "Toolbars" tab
* In category select "ABTO Tools"
* Drag and drop the "ABTOUV" item to your toolbar. The button will appear.

* To launch the script press that button.

* To update script to a new version just drag and drop the new version of the *.mcr file from Windows Explorer to the 3ds Max window.

## 4. Version history

### v0.1 @ 2017-01-21

* Initial release

### v0.2 @ 2017-01-22

* Now comparing UVs while welding without W-coordinate
* Ability to weld only by U or only by V coordinates
* Slightly improved interface
* Minor bugfixes
* Created project on GitHub

### v0.3 @ 2017-01-23

* Added presets for welding thresholds
* Saves the selected threshold into config file


## 5. To-Do

* Add Collapse UV button
* Add align to edge functionality
