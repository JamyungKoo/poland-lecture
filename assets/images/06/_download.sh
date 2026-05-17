#!/bin/bash
set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

fetch() {
  local fn="$1"; local out="$2"; local w="${3:-1024}"
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

# 가이드 투어 정거장 순서대로
# 1. 중앙역
fetch "Warszawa-Centralna & al.png" "01-centralna-station.png" 1024
# 2. 문화과학궁전
fetch "Palace of Culture and Science, Warsaw (by Pudelek).jpg" "02-palace-culture.jpg" 1024
# 3. 사스키 광장 — 무명용사의 묘
fetch "A military ceremony in front of the Tomb of the Unknown Soldier in Warsaw.jpg" "03-unknown-soldier.jpg" 1024
# 4. 사스키 정원
fetch "Warsaw 2023 244 Saxon Garden Fountain.jpg" "04-saxon-garden.jpg" 1024
# 5. 코페르니쿠스 동상 (토르발센)
fetch "Copernicus by Thorwaldsen Warsaw 02.jpg" "05-copernicus-monument.jpg" 800
# 6. 바르샤바 대학 정문
fetch "Warsaw 2023 109 University Main Gate.jpg" "06-uw-gate.jpg" 1024
# 7. 성 십자가 교회 (쇼팽 심장)
fetch "Chopin heart Holy Cross church Warsaw.jpg" "07-chopin-heart.jpg" 800
# 8. 노비 시비아트 거리
fetch "2023-01-08 Nowy Świat Street in Warsaw 1.jpg" "08-nowy-swiat.jpg" 1024
# 9. 왕궁 광장 — Zygmunt 기둥
fetch "Warsaw 2023 035 Sigismund Column Statue Dusk.jpg" "09-zygmunt-column.jpg" 1024
# 10. 왕궁
fetch "Royal Castle in Warsaw 2020.jpg" "10-royal-castle.jpg" 1280
# 11. 구시가지 광장 + 인어상
fetch "The Mermaid of Warsaw sculpture in Old Town Market Place.jpg" "11-mermaid.jpg" 800
# 12. 바르비칸
fetch "Barbakan Warszawski (34173895453).jpg" "12-barbican.jpg" 1024
# 13. 신 시가지 광장
fetch "New Town Market Square, Warsaw 03.jpg" "13-new-town.jpg" 1024
# 14. 게토 영웅 추모비 (종착)
fetch "Monument to the Ghetto Heroes, Warsaw.JPG" "14-ghetto-monument.jpg" 1024
# 15. 봉기 박물관 (추천 연장)
fetch "Muzeum Powstania Warszawskiego 2023.jpg" "15-uprising-museum.jpg" 1024

ls -la *.jpg *.JPG *.png 2>/dev/null
