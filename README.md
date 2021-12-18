# ManifestDestinyDB
Automated Repository of records for manifest destiny

Not in anyway complete yet, some things will work in the future, some things may break, here be dragons etc etc. Good luck. 

## List of thing you will need:
- Patience (the virtue)
- aapt
- unzip
- android-tools (probably)
- imagemagick
- curl
- a tonne of apks
- manifestdestiny-hugo

## What everything does:

- BuildRecord.sh
    - Run an apk through both exodus for getting trackers and through our manifest extraction process then append any network data we have
- genApps.sh
    - Build a markdown file for a given .json record of an app
- genCategories.sh
    - Generate a set of category pages to sort the apps into from (generated from otherdata file)
- genPermissions.sh
    - Generate individual pages for each of the permissions mentioned in the otherData (and add definitions)
- genTrackers.sh
    - Generate Catagory pages for each tracker
- Manifest.sh
    - The bulk of the code for converting .apk files into our .json format, as well as adding icons to the webpages for the apps (as gotten from the PlayStore)
- splitPermissionDB.sh
    - splits otherData permission databases into individual .json files

### Misc Scripts:

- AndroidPermissionsInAJSONPlease.sh
    - Takes latest AndroidManifest.xml file from latest android commit and covers it into a permissionsDatabase.json for the otherData directory (very messy but probably wont break), this gives definitions of permissions that are given in the Android Source Code.
- bsonPacketsToJson.sh (optional)
    - Converts bson files into csv files (this was used to extract the network data)
- genConnections.sh
    - creating pages for the network connnections
- generateFull.sh
    - runs ./genApps.sh on every manifest in ~/manifests/*.json
- genPermissionExtraDB.sh
    - Takes a list of permissions and line by line formats it into the unknownPermissionDB file
- genPermissionPage.sh
    - generates the page with the list of permissions on
- mergeConnectionsWithManifests.sh
    - appends connection data to manifest data
- toGEXF.sh
    - converts various data we collect into a graph file for analysis

This project uses data from:

    Lyngs, U., & Binns, R. (2018, April 27). 
    WebSci’18: Third party tracking in the mobile ecosystem. 
    https://doi.org/10.17605/OSF.IO/4NU9E

    Abbas Razaghpanah, Arian Akhavan Niaki, Narseo Vallina-Rodriguez, Srikanth Sundaresan, 
    Johanna Amann, and Phillipa Gill. 
    2017. "Studying TLS Usage in Android Apps", 
    ACM International Conference on emerging Networking EXperiments and Technologies (CoNEXT) 2017
