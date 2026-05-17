#!/bin/bash
# 2회차 이미지 다운로드 (Wikimedia Commons)
set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

fetch() {
  local fn="$1"; local out="$2"; local w="${3:-1280}"
  echo "→ $fn → $out"
  # python3로 URL 인코딩하여 안전 호출
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

# 1. 폴란드-리투아니아 연방 최대 영토 (1619)
fetch "Polish-Lithuanian Commonwealth in 1619.PNG" "commonwealth-1619.png" 1280

# 2. 그룬발트 전투 — 얀 마테이코 (1878)
fetch "Jan Matejko, Bitwa pod Grunwaldem.jpg" "grunwald-matejko.jpg" 1600

# 3. 1791년 5월 3일 헌법 — 얀 마테이코
fetch "Constitution of May 3, 1791 by Jan Matejko.PNG" "constitution-may3.png" 1600

# 4. 폴란드 분할 지도 (1772/1793/1795)
fetch "Partitions of Poland.png" "partitions.png" 1280

# 5. 유제프 피우수트스키 — 1918 독립의 영웅
fetch "Pilsudski 1910 1920 LOC hec 14263 restored.jpg" "pilsudski.jpg" 800

# 6. 바르샤바 봉기 폐허 (1944)
fetch "Warsaw Uprising by Chrzanowski - Ruins - 14640.jpg" "warsaw-uprising-ruins.jpg" 1280

# 7. 아우슈비츠 정문 — "Arbeit Macht Frei"
fetch "The arbeit macht frei gate in Auschwitz I.jpg" "auschwitz-gate.jpg" 1280

# 8. 그단스크 조선소 (1980 8월)
fetch "Solidarity August 1980 gate of Gdańsk Shipyard.jpg" "gdansk-shipyard-1980.jpg" 1280

# 9. 레흐 바웬사 (1980)
fetch "Lech Wałęsa 1980.jpg" "walesa-1980.jpg" 800

# 10. 요한 바오로 2세
fetch "Portrait of the Pope John Paul II.JPG" "john-paul-ii.jpg" 800

echo ""
ls -la *.png *.jpg *.JPG 2>/dev/null
