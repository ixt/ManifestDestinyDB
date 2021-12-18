# This is against Android ToS (probably)

1. Get https://github.com/google/android-emulator-container-scripts
2. Get the various things required to run it
3. Configure to latest stable emulator and latest android-image with google-play (you can tell from its name)
4. Run the web container scripts, log in or register an account you do not mind
   being blocked (hasnt happened to me but it might eventually)
    4.1. if it doesnt work replace the dockerfile at js/jwt-provider/Dockerfile 
5. Once you're up and running run install-on-emulator.sh it will go through and
   install from the playstore any apps listed in apkslist.list by looking them
   up on the store. You will need hocr to do OCR and android-tools/ADB to click buttons automatically
    5.1. its not perfect so keep an eye on it and click buttons it misses
    5.2. it will run out of space, extract the apks that are on the device with HAndHold if need be or change apklist to include them first on the next run so that it cleans up those apps.
    5.3. this can probably be improved by changing the docker volume size to be very large (enough to install all apks watched) and to update automatically, reload on updates etc, this is going would likely ring alarmbells but I do not know the limits so by default it cleans up after itself

