#!/bin/bash
for file in $(ls -1 manifests/*.json); do
    ./genApps.sh $file
done
