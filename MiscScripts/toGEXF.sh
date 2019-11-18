#!/bin/bash
TRACKERLOOKUP=$(mktemp)
jq -r ".trackers[]" manifestdestinydb/manifests/* | sort -u  | nl -w1 -s' ' > $TRACKERLOOKUP
APPLOOKUP=$(mktemp)
ls -1 manifestdestinydb/manifests/*.json | cut -d"/" -f3-| sed -e"s/\.json$//g" | nl -w1 -s' ' > $APPLOOKUP

cat <<EOF > 20191118.gexf
<?xml version="1.0" encoding="UTF-8"?>
<gexf xmlns="http://www.gexf.net/1.3" version="1.3" xmlns:viz="http://www.gexf.net/1.3/viz" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.gexf.net/1.3 http://www.gexf.net/1.3/gexf.xsd">
  <meta lastmodifieddate="2019-11-18">
    <creator>Gephi 0.9</creator>
    <description></description>
  </meta>
  <graph defaultedgetype="directed" mode="static">
    <attributes class="node" mode="static">
      <attribute id="type" title="type" type="string"></attribute>
      <attribute id="category" title="category" type="string"></attribute>
    </attributes>
    <attributes class="edge" mode="static">
      <attribute id="permission" title="Permission" type="string"></attribute>
    </attributes>

    <nodes>
EOF

while read app; do
    APPCOUNT=$(cut -d' ' -f1 <<<"$app")
    APPNAME=$(cut -d' ' -f2- <<<"$app")
    MANIFEST="manifestdestinydb/manifests/$APPNAME.json"
    CATEGORY=$(jq -r ".category" $MANIFEST)
cat <<EOF >> 20191118.gexf
      <node id="app${APPCOUNT}" label="${APPNAME}">
        <attvalues>
          <attvalue for="type" value="${APPNAME}"></attvalue>
          <attvalue for="category" value="${CATEGORY}"></attvalue>
        </attvalues>
      </node>

EOF
done < $APPLOOKUP

while read tracker; do
    TRACKERCOUNT=$(cut -d' ' -f1 <<<"$tracker")
    TRACKERNAME=$(cut -d' ' -f2- <<<"$tracker")
cat <<EOF >> 20191118.gexf
      <node id="tracker${TRACKERCOUNT}" label="${TRACKERNAME}">
        <attvalues>
          <attvalue for="type" value="SDK"></attvalue>
        </attvalues>
      </node>

EOF
done < $TRACKERLOOKUP
cat <<EOF >> 20191118.gexf
    </nodes>

    <edges>
EOF

EDGECOUNT=0
TRACKERS=$(mktemp)
while read app; do
    APPCOUNT=$(cut -d' ' -f1 <<<"$app")
    APPNAME=$(cut -d' ' -f2- <<<"$app")
    MANIFEST="manifestdestinydb/manifests/$APPNAME.json"
    jq -r '.trackers[]' $MANIFEST > $TRACKERS


    PERMISSIONLINE=$(jq -r ".permissions | @csv " $MANIFEST | sed -e 's/","/|/g;s/"//g')

    WEIGHT=$(jq -r ".permissions | @csv " $MANIFEST \
        | sed -e 's/","/|/g;s/"//g' \
        | tr '|' '\n' \
        | sort -u \
        | wc -l)
if [[ -n $TRACKERS ]]; then
    while read TRACKER; do
        TRACKERLINE=$(egrep "$TRACKER$" $TRACKERLOOKUP)
        TRACKERCOUNT=$(cut -d' ' -f1 <<<"$TRACKERLINE")
cat <<EOF >> 20191118.gexf
      <edge id="${EDGECOUNT}" source="app${APPCOUNT}" target="tracker${TRACKERCOUNT}" weight="${WEIGHT}">
        <attvalues>
          <attvalue for="permission" value="${PERMISSIONLINE}"></attvalue>
        </attvalues>

      </edge>
EOF
    EDGECOUNT=$(( $EDGECOUNT + 1 ))
    done < $TRACKERS
fi
done < $APPLOOKUP

cat <<EOF >> 20191118.gexf
    </edges>
  </graph>
</gexf>
EOF

