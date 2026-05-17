#!/bin/bash
set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

fetch() {
  local fn="$1"; local out="$2"; local w="${3:-1280}"
  echo "→ $fn → $out"
  local url=$(python3 -c "
import urllib.parse, urllib.request, json
fn = '''$fn'''
enc = urllib.parse.quote(fn)
api_url = '$API?action=query&titles=File:' + enc + '&prop=imageinfo&iiprop=url&iiurlwidth=$w&format=json'
req = urllib.request.Request(api_url, headers={'User-Agent':'$UA'})
data = json.load(urllib.request.urlopen(req, timeout=30))
p = next(iter(data['query']['pages'].values()))
if 'imageinfo' in p:
    u = p['imageinfo'][0].get('thumburl') or p['imageinfo'][0].get('url')
    print(u.split('?')[0])
")
  if [ -z "$url" ]; then echo "  ✗ no url"; return; fi
  curl -sL -A "$UA" -o "$out" "$url"
  local sz=$(stat -f%z "$out" 2>/dev/null || stat -c%s "$out")
  echo "  ✓ $sz bytes"
}

fetch "Warsaw Gdansk Bridge aerial photograph 2019.jpg" "warsaw-aerial.jpg" 1280
fetch "Destroyed Warsaw, capital of Poland, January 1945.jpg" "warsaw-1945-ruins.jpg" 1280
fetch "Palace of Culture and Science, Warsaw (by Pudelek).jpg" "palace-culture-science.jpg" 1280
fetch "The Mermaid of Warsaw sculpture in Old Town Market Place.jpg" "warsaw-mermaid.jpg" 800
fetch "Monument to the Ghetto Heroes, Warsaw.JPG" "ghetto-heroes-monument.jpg" 1024
fetch "Maria Sklodowska-Curie birthplace mural.jpg" "curie-warsaw.jpg" 1024
fetch "Muzeum Powstania Warszawskiego 2023.jpg" "uprising-museum.jpg" 1280
fetch "Royal Castle in Warsaw 2020.jpg" "royal-castle.jpg" 1280

ls -la *.jpg *.JPG 2>/dev/null
