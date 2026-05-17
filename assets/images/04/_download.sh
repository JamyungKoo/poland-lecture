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

# 크라쿠프 광장 (Sukiennice)
fetch "2025, Kraków, Sukiennice, Rynek Główny (15).jpg" "krakow-rynek.jpg" 1280
# 바벨 성
fetch "Wawel Castle view from south. Krakow, Poland.jpg" "krakow-wawel.jpg" 1280
# 그단스크 마리아츠카 거리 (호박길)
fetch "Gdańsk Główne Miasto, Ulica Mariacka - panoramio.jpg" "gdansk-mariacka.jpg" 1280
# 브로츠와프 광장·시청
fetch "2019-07-02 Wroclaw market square.jpg" "wroclaw-rynek.jpg" 1280
# 브로츠와프 난쟁이 (펜싱 검사 난쟁이)
fetch "Szermierz (Swordsman) Wroclaw dwarf dressed 2016 P01.jpg" "wroclaw-dwarf.jpg" 600
# 자코파네 - 크루포브키 거리
fetch "Zakopane Krupowki 10 Muzeum Tatrzanskie03 A-1130 M.JPG" "zakopane.jpg" 1024
# 피에로기 루스키에 (러시아식 피에로기 — 폴란드 대표 만두)
fetch "Pierogi ruskie w śmietanie.jpg" "pierogi.jpg" 800
# 비고스 (헌터 스튜)
fetch "Bigos in Kraków (Rynek Główny).jpg" "bigos.jpg" 800
# 주레크 (사워 라이 수프)
fetch "Zurek Sour Rye Soup, Warsaw.jpg" "zurek.jpg" 800

echo ""
ls -la *.jpg *.JPG 2>/dev/null
