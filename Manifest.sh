#!/bin/bash
PERMISSIONS=$(mktemp)
TEMP=$(mktemp)
aapt d xmltree "$1" AndroidManifest.xml \
    | grep "android:name" \
    | grep "permission" \
    | cut -d'"' -f 4 \
        > $PERMISSIONS
if [[ ! -s $PERMISSIONS ]]; then
aapt d xmltree "$1" AndroidManifest.xml \
    | grep permission \
    | cut -d'"' -f 2 \
    | sed -e "/:/d" \
        > $PERMISSIONS
fi
if [[ ! -s $PERMISSIONS ]]; then
    mkdir .tmp
    pushd .tmp
    unzip $1 
    if [[ -s manifest.json ]]; then
        jq -r .permissions manifest.json
            > $PERMISSIONS
            version=$(jq -r .version_name manifest.json)
            appname=$(jq -r .name manifest.json)
            package=$(jq -r .package_name manifest.json)
            convert icon.* ../$package.png
    fi
    popd
    rm .tmp -rf
fi

filename=$(echo "$1" | cut -d/ -f 3)
if [[ "$version" == "" ]]; then
version=$(aapt d --values badging $1 \
    | egrep -o "versionName='[^']*'" \
    | cut -d"'" -f2 )
appname=$(aapt d --values badging $1 \
    | grep "application-label-en" \
    | head -1 \
    | cut -d"'" -f2 )
if [[ "$appname" == "" ]]; then
    appname=$(aapt d --values badging $1 \
        | grep "application: label=" \
        | head -1 \
        | cut -d"'" -f2 )
fi
if [[ "$appname" == "" ]]; then
    appname=$(aapt d --values badging $1 \
        | grep "^launchable-activity" \
        | egrep -o "label='[^']*'" \
        | cut -d"'" -f2 )
fi
package=$(aapt d --values badging $1 \
    | egrep -o "package: name='[^']*'" \
    | cut -d"'" -f2 )
iconpath=$(aapt d --values badging $1 \
    | grep "application-icon" \
    | sed "/\.xml/d" \
    | tail -1 \
    | cut -d ":" -f2 \
    | sed "s/'//g") 
iconname=$(basename "$iconpath")
iconext="${iconname##*.}"
unzip -p $1 $iconpath > $package.$iconext
fi
category=$(curl -s "https://play.google.com/store/apps/details?id=$package" \
    | grep 'itemprop="genre"' \
    | egrep -o "https://play\.google\.com/store/apps/category/[A-Z_]*" \
    | sed -e "s/.*\///g")

if [[ ! -s "$package.png" ]]; then
    echo "second attempt $package" >&2
    iconpath=$(unzip -l $1 \
        | grep "ic_launcher.png" \
        | cut -d":" -f2 \
        | cut -d" " -f 4- \
        | tail -1 )
    iconname=$(basename "$iconpath")
    iconext="${iconname##*.}"
    unzip -p $1 $iconpath > $package.$iconext
fi

if [[ ! -s "$package.png" ]]; then
    echo "hey $package" >&2
    curl -s "https://play.google.com/store/apps/details?id=$package" \
        | grep "Cover art" \
        | egrep -o 'src="[^"]*"' \
        | cut -d'"' -f2 \
        | xargs -I@ wget "@" -O $package.png
fi
if [[ ! -s "$package.png" ]]; then
    convert $package.$iconext $package.png
    rm $package.$iconext
fi
mv $package.png ~/manifestdestiny-hugo/content/assets/icons/
if [[ -s "$package." ]]; then
    rm $package.
fi

cat <<EOF
{
    "appName": "$appname",
    "packageName": "$package",
    "category": "$category",
    "icon": "$icon64",
    "permissions": [
EOF
while read permission; do
    echo "          \"$permission\", " >> $TEMP
done < <( sort -u $PERMISSIONS )
sed -i -e '$s/,//g' $TEMP
cat $TEMP
cat <<EOF
    ],
    "version": "$version"
}
EOF
rm $TEMP
