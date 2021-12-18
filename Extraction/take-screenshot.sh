#Create a temporary folder to save a screenshot.
mkdir tmp
rm tmp/screen.png &>/dev/null
#Capture a screenshot and save to /sdcard/screen.png on your Android divice.
adb -s emulator-5554 shell screencap -p /sdcard/screen.png

#Grab the screenshot from /sdcard/screen.png to /tmp/screen.png on your PC.
adb -s emulator-5554 pull /sdcard/screen.png tmp/screen.png

#Delete /sdcard/screen.png
adb -s emulator-5554 shell rm /sdcard/screen.png

#open the screenshot on your PC. 
display tmp/screen.png
