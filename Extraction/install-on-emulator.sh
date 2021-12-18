#!/bin/bash
set -x -v
timeout=30
timebeforeclick="2s"

device="localhost:5555"

timeout_screenshot(){
    mkdir timeout &>/dev/null
    adb -s $device shell screencap -p /sdcard/screen.png
    adb -s $device pull /sdcard/screen.png timeout/$1.png
    adb -s $device shell rm /sdcard/screen.png
}

screenshot(){
    adb -s $device shell screencap -p /sdcard/screen.png
    adb -s $device pull /sdcard/screen.png screen.png
    adb -s $device shell rm /sdcard/screen.png
    tesseract screen.png screen.txt hocr
}

do_with_ocr(){
    if [[ -s screen.txt.hocr ]]; then
        aclocation=$(grep ACCEPT screen.txt.hocr \
            | sed "s/.*\('bbox [^']*'\).*/\1/g" | cut -d' ' -f2,3)
        [[ $aclocation != '' ]] && adb -s $device shell input touchscreen tap $aclocation 
        inlocation=$(grep "Install" screen.txt.hocr \
            | sed "s/.*\('bbox [^']*'\).*/\1/g" | cut -d' ' -f2,3)
        [[ $inlocation != '' ]] && adb -s $device shell input touchscreen tap $inlocation 
        golocation=$(grep "Got" screen.txt.hocr \
            | sed "s/.*\('bbox [^']*'\).*/\1/g" | cut -d' ' -f2,3)
        [[ $golocation != '' ]] && adb -s $device shell input touchscreen tap $golocation 
        relocation=$(grep "found." screen.txt.hocr \
            | sed "s/.*\('bbox [^']*'\).*/\1/g" | cut -d' ' -f2,3)
        [[ $relocation != '' ]] && : $(( count = $timeout + 1 ))
        colocation=$(grep "country." screen.txt.hocr \
            | sed "s/.*\('bbox [^']*'\).*/\1/g" | cut -d' ' -f2,3)
        [[ $colocation != '' ]] && : $(( count = $timeout + 1 )) && echo "$1" >> countrymissing
        # Failsafe
        [[ $count == 1 ]] && adb -s $device shell input touchscreen tap 708 100 
        [[ $count == 2 ]] && adb -s $device shell input touchscreen tap 908 910 
    fi
}

open_play_with_id(){
    adb -s $device shell am start -a android.intent.action.VIEW -d "market://details?id=$1"
}

for package in $(sed -e "s/\.apk$//g" ./apklist.list); do
        if ! [[ -s ./apks/$package.apk ]]; then
            if ! [[ -s "timeout/$package.png" ]]; then
                open_play_with_id $package
                FILEPATH=""
                sleep $timebeforeclick
                adb -s $device shell input touchscreen tap 908 810 
                
                count=0
                skip=0
                while ! grep ".apk" <<< "$FILEPATH"; do
                    screenshot 
                    do_with_ocr "$package"
                    FILEPATH=$(adb -s $device shell pm list packages -f \
                        | grep $package \
                        | sed -e "s/^package://" -e "s/base\.apk=.*/base.apk/"
                    )
                    if [[ $count -gt $timeout ]];then
                        skip=1 
                        echo "$package" >> timedout 
                        timeout_screenshot $package
                        break
                    fi
                    sleep 1s
                    : $(( count += 1 ))
                done
                if [[ $skip -eq 0 ]]; then
                    adb -s $device pull $FILEPATH "./apks/$package.apk"
                    adb -s $device shell pm uninstall -k --user 0 $package
                    rm screen.txt.hocr
                fi
        fi
    fi
done
