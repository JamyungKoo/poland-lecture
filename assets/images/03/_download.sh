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

# 쇼팽 (들라크루아, 1838)
fetch "Eugène Delacroix - Frédéric Chopin - WGA06194.jpg" "chopin-delacroix.jpg" 800
# 미츠키에비치 (Wańkowicz, 1828)
fetch "Walenty Wańkowicz - Portrait of Adam Mickiewicz on the rock of Judah - MP 309 - National Museum in Warsaw.jpg" "mickiewicz.jpg" 800
# 시엔키에비치 (1885, 노벨문학상 1905)
fetch "Henryk Sienkiewicz ca 1885 (45871548) (cropped).jpg" "sienkiewicz.jpg" 600
# 시밍보르스카 (노벨문학상 1996)
fetch "Wisława Szymborska 2009.10.23 (1).jpg" "szymborska.jpg" 800
# 토카르추크 (노벨문학상 2018)
fetch "MJK32706 Olga Tokarczuk (Pokot, Berlinale 2017).jpg" "tokarczuk.jpg" 800
# 바이다 (영화 감독)
fetch "Andrzej-Wajda-1963.jpg" "wajda.jpg" 600
# 키에슬로프스키 (영화 감독)
fetch "Krzysztof Kieślowski Portrait 1994.jpg" "kieslowski.jpg" 600
# 코페르니쿠스
fetch "Nicolaus Copernicus. Reproduction of line engraving.jpg" "copernicus.jpg" 600
# 마리 퀴리
fetch "Marie Curie c. 1920s.jpg" "curie.jpg" 600

echo ""
ls -la *.jpg
