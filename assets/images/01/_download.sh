#!/bin/bash
# Wikimedia Commons 이미지 다운로드 스크립트
# API를 통해 정확한 thumb URL을 받고 다운로드

set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

fetch_image() {
  local filename="$1"
  local outname="$2"
  local width="${3:-1024}"

  echo "→ ${filename} (${width}px) → ${outname}"
  # API로 thumbnail URL 받기
  local response
  response=$(curl -sL -A "$UA" "${API}?action=query&titles=File:${filename}&prop=imageinfo&iiprop=url&iiurlwidth=${width}&format=json")
  local url
  url=$(echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
pages = data['query']['pages']
page = next(iter(pages.values()))
info = page['imageinfo'][0]
url = info.get('thumburl') or info.get('url')
# strip query params
print(url.split('?')[0])
")
  if [ -z "$url" ]; then
    echo "  ✗ URL 추출 실패: $filename"
    return 1
  fi
  echo "  url: $url"
  curl -sL -A "$UA" -o "$outname" "$url"
  local size
  size=$(stat -f%z "$outname" 2>/dev/null || stat -c%s "$outname")
  echo "  ✓ ${size} bytes"
}

# 1. 유럽 내 폴란드 위치
fetch_image "Poland_in_Europe_(-rivers_-mini_map).svg" "europe-poland-location.png" 1024

# 2. 폴란드 지형도
fetch_image "Poland_topo.jpg" "poland-topo.jpg" 1280

# 3. 폴란드 국장 (백독수리)
fetch_image "Herb_Polski.svg" "poland-coat-of-arms.png" 800

# 4. 폴란드 국기
fetch_image "Flag_of_Poland.svg" "poland-flag.png" 1024

# 5. 쇼팽 다게레오타입 (1849)
fetch_image "Frederic_Chopin_photo_downsampled.jpeg" "chopin-1849.jpg" 600

# 6. 타트라 산맥
fetch_image "Morskie_Oko_(2017-08-13).jpg" "tatra-morskie-oko.jpg" 1280

# 7. 바르샤바 구시가지 (예고용)
fetch_image "Warsaw_old_town_2014.JPG" "warsaw-old-town.jpg" 1280

# 8. 야스나 고라 수도원 (가톨릭 상징)
fetch_image "Jasna_Góra_Monastery_in_Częstochowa,_Poland.JPG" "jasna-gora.jpg" 1024

echo ""
echo "=== 다운로드 결과 ==="
ls -la *.png *.jpg 2>/dev/null | grep -v _download
