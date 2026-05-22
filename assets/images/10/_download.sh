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
enc = urllib.parse.quote(fn)
api_url = '$API?action=query&titles=File:' + enc + '&prop=imageinfo&iiprop=url&iiurlwidth=$w&format=json'
req = urllib.request.Request(api_url, headers={'User-Agent':'$UA'})
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
q = '''$query'''
enc = urllib.parse.quote(q)
api_url = '$API?action=query&list=search&srsearch=' + enc + '&srnamespace=6&srlimit=5&format=json'
req = urllib.request.Request(api_url, headers={'User-Agent':'$UA'})
data = json.load(urllib.request.urlopen(req, timeout=30))
results = data.get('query', {}).get('search', [])
for r in results:
    t = r['title']
    if t.lower().endswith(('.jpg', '.jpeg', '.png')):
        print(t[5:])
        break
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

try "Dworzec kolejowy Zakopane.jpg"             "01-zakopane-station.jpg"    "Dworzec Zakopane PKP"
try "Krupówki w Zakopanem.jpg"                  "02-krupowki-north.jpg"      "Krupówki Zakopane"
try "Muzeum Tatrzańskie w Zakopanem.jpg"        "03-muzeum-tatrzanskie.jpg"  "Muzeum Tatrzańskie Zakopane"
try "Willa Atma w Zakopanem.jpg"                "04-villa-atma.jpg"          "Willa Atma Szymanowski Zakopane"
try "Stary Kościół Zakopane.jpg"                "05-stary-kosciol.jpg"       "Stary Kościół Zakopane drewniany"
try "Cmentarz Zasłużonych na Pęksowym Brzyzku.jpg" "06-peksow-brzyzek.jpg"   "Cmentarz Pęksowy Brzyzek Zakopane"
try "Willa Koliba w Zakopanem.jpg"              "07-willa-koliba.jpg"        "Willa Koliba Zakopane Witkiewicz"
try "Oscypek na grillu.jpg"                     "08-oscypek-stall.jpg"       "Oscypek Krupówki street"
try "Gubałówka widok.jpg"                       "09-gubalowka.jpg"           "Gubałówka Tatry panorama"
try "Kasprowy Wierch szczyt.jpg"                "courseB-kasprowy.jpg"       "Kasprowy Wierch szczyt"
try "Morskie Oko 1.jpg"                         "courseC-morskie-oko.jpg"    "Morskie Oko Tatry lake"

ls -la *.jpg 2>/dev/null
