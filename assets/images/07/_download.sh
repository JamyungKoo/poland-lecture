#!/bin/bash
set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

fetch() {
  local fn="$1"; local out="$2"; local w="${3:-1280}"
  echo "→ $out"
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
  echo "  ✓ $(stat -f%z "$out" 2>/dev/null || stat -c%s "$out") bytes"
}

fetch "Krakow - Wawel from balloon - 2.jpg" "krakow-aerial.jpg" 1280
fetch "Wavel Cathedral (9361151440).jpg" "wawel-cathedral.jpg" 1024
fetch "Courtyard of the Collegium Maius (Kraków), 2019.jpg" "collegium-maius.jpg" 1024
fetch "Old Jewish (Remah) Cemetery and Remah Synagogue, 40 Szeroka Street, Kazimierz, Kraków, Poland.jpg" "kazimierz-synagogue.jpg" 1024
fetch "Image of Oskar Schindler with Testimony - Krakow 1939-1945 Museum - In Oskar Schindler's Factory - Krakow - Poland (9195678018).jpg" "schindler-factory.jpg" 1024
fetch "Nowa Huta - Plac Centralny z lotu ptaka.jpg" "nowa-huta.jpg" 1280
fetch "20240624 190424 Plac Nowy sercem Kazimierza 02.jpg" "plac-nowy-kazimierz.jpg" 1024
fetch "Rynek Główny Sukiennice (8475793773).jpg" "rynek-sukiennice.jpg" 1280

ls -la *.jpg *.JPG 2>/dev/null
