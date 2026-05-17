#!/bin/bash
set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

fetch() {
  local fn="$1"; local out="$2"; local w="${3:-1024}"
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

# 코스 A 정거장 순서
fetch "Former Kraków Główny railway station and Jan Nowak-Jeziorański square (bird's eye view, 2025), Kraków, Poland.jpg" "01-glowny-station.jpg" 1024
fetch "Planty Park, Florian Gate, Barbican, Old Town, Kraków, Poland.jpg" "02-barbican-florian.jpg" 1024
fetch "20200516 Ulica Floriańska i Kościół Mariacki w Krakowie 0914 9971.jpg" "03-florianska-street.jpg" 1024
fetch "Rynek Główny Sukiennice (8475793773).jpg" "04-rynek-sukiennice.jpg" 1280
fetch "Krakow 2024 030 St Mary Basilica - Tops of Towers.jpg" "05-mariacka-towers.jpg" 1024
fetch "Courtyard of the Collegium Maius (Kraków), 2019.jpg" "06-collegium-maius.jpg" 1024
fetch "Wawel Castle view from south. Krakow, Poland.jpg" "07-wawel-castle.jpg" 1280
fetch "Wavel Cathedral (9361151440).jpg" "08-wawel-cathedral.jpg" 1024
fetch "Wawel Dragon monument. Krakow, Poland.jpg" "09-wawel-dragon.jpg" 800
fetch "20240624 190424 Plac Nowy sercem Kazimierza 02.jpg" "10-plac-nowy.jpg" 1024
fetch "Old Jewish (Remah) Cemetery and Remah Synagogue, 40 Szeroka Street, Kazimierz, Kraków, Poland.jpg" "11-remah-synagogue.jpg" 1024
fetch "Image of Oskar Schindler with Testimony - Krakow 1939-1945 Museum - In Oskar Schindler's Factory - Krakow - Poland (9195678018).jpg" "12-schindler-factory.jpg" 1024

# 코스 B — 아우슈비츠
fetch "The arbeit macht frei gate in Auschwitz I.jpg" "courseB-auschwitz-gate.jpg" 1280

ls -la *.jpg *.JPG 2>/dev/null
