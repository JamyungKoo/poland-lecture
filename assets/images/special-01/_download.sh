#!/bin/bash
set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

fetch() {
  local fn="$1"; local out="$2"; local w="${3:-1280}"
  echo "→ $out  (file: $fn)"
  local url=$(python3 -c "
import urllib.parse, urllib.request, json
fn = '''$fn'''
api = '$API?action=query&titles=File:' + urllib.parse.quote(fn) + '&prop=imageinfo&iiprop=url&iiurlwidth=$w&format=json'
req = urllib.request.Request(api, headers={'User-Agent':'$UA'})
data = json.load(urllib.request.urlopen(req, timeout=30))
p = next(iter(data['query']['pages'].values()))
if 'imageinfo' in p:
    u = p['imageinfo'][0].get('thumburl') or p['imageinfo'][0].get('url')
    print(u.split('?')[0])
")
  if [ -z "$url" ]; then echo "  ✗ no url"; return 1; fi
  curl -sL -A "$UA" -o "$out" "$url"
  echo "  ✓ $(stat -f%z "$out" 2>/dev/null || stat -c%s "$out") bytes"
}

search_fetch() {
  local query="$1"; local out="$2"; local w="${3:-1280}"
  echo "→ $out  (search: $query)"
  local fn=$(python3 -c "
import urllib.parse, urllib.request, json
api = '$API?action=query&list=search&srsearch=' + urllib.parse.quote('$query') + '&srnamespace=6&srlimit=10&format=json'
req = urllib.request.Request(api, headers={'User-Agent':'$UA'})
data = json.load(urllib.request.urlopen(req, timeout=30))
for r in data.get('query', {}).get('search', []):
    t = r['title']
    if t.lower().endswith(('.jpg','.jpeg','.png','.svg')):
        print(t[5:]); break
")
  if [ -z "$fn" ]; then echo "  ✗ no search result"; return 1; fi
  echo "  → matched: $fn"
  fetch "$fn" "$out" "$w" || return 1
}

try() {
  local file="$1"; local out="$2"; local search="$3"; local w="${4:-1280}"
  if ! fetch "$file" "$out" "$w" 2>/dev/null; then
    echo "  retry by search..."
    search_fetch "$search" "$out" "$w" || echo "  ✗✗ both failed: $out"
  fi
}

try "Poland 1939 invasion map.svg"           "poland-partition-1939.jpg"  "1939 German Soviet Polish partition map"
try "Litzmannstadt Ghetto.jpg"               "lodz-ghetto.jpg"            "Litzmannstadt Lodz ghetto"
try "Warschauer Ghettomauer.jpg"             "warsaw-ghetto-wall.jpg"     "Warsaw ghetto wall mur"
try "Ringelblum archive.jpg"                 "ringelblum-archive.jpg"     "Ringelblum Oneg Shabbat archive milk can"
try "Schloss Hartheim 2010.jpg"              "t4-hartheim.jpg"            "Schloss Hartheim T4 euthanasia"
try "Einsatzgruppen map.svg"                 "einsatzgruppen-map.jpg"     "Einsatzgruppen map Soviet Union 1941"
try "Haus der Wannsee-Konferenz.jpg"         "wannsee-villa.jpg"          "Haus Wannsee Konferenz Villa"

ls -la *.jpg 2>/dev/null
