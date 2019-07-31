#/bin/bash
TEMP=$(mktemp)
TEMP_TRACKERS=$(mktemp)
package=${1}
OUT=$(mktemp)

FULLPATH=$(readlink -f $package)
./Manifest.sh "${FULLPATH}" > $TEMP
PKGNAME=$(jq -r .packageName $TEMP)

rm -rf .tmp/ >/dev/null
pushd ./otherData/exodus-standalone/
    source env/bin/activate
    
    python exodus_analyze.py $FULLPATH > $TEMP_TRACKERS
    if grep -q "trackers" $TEMP_TRACKERS; then 
    
        lineNo=$(( 1 + $(grep -n "trackers" $TEMP_TRACKERS | cut -f 1 -d:) ))
        
        # This is a bad way to do this, it works but is a nasty workaround
        tail -n+$lineNo $TEMP_TRACKERS \
            | cut -f3- -d" " \
            | sed -e "s/^/\"/g" -e "s/$/\",/g" \
            | tee $OUT
        
    fi
    deactivate
popd
jq -s add $TEMP \
    <(echo '{"trackers": ' \
        $(echo '[' $(cat $OUT) \
                | sed -e "s/,$//g") ']}') \
    > ./manifests/$PKGNAME.json
TEMP2=$(mktemp)
TEMPM=$(mktemp)

for file in $(ls -1 ./manifests/$PKGNAME.json | cut -d"/" -f 3- | sed -e "s/\.json//g" ); do
    changes=0
	cat <<EOF > $TEMP2
	{ "network_connections" : [
EOF
	for packet in $(ls -1 packets/handshakes/$PKGNAME*); do
        changes=1
		cat $packet >> $TEMP2
		echo "," >> $TEMP2
	done
	sed -i '$s/,$//' $TEMP2
	cat <<EOF >> $TEMP2
	] }
EOF

jq -s add ./manifests/$file.json $TEMP2 \
    > $TEMPM
if [[ "$changes" -eq "1" ]]; then
    cat $TEMPM
    echo $file
    cp $TEMPM ./manifests/$file.json
fi

done

rm $TEMP2 $TEMPM

rm -rf $OUT $TEMP $TEMP_TRACKERS
