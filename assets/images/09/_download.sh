#!/bin/bash
set -e
UA="PolandLectureBot/1.0 (contact: jamyung.koo@bagelcode.com)"
API="https://commons.wikimedia.org/w/api.php"
cd "$(dirname "$0")"

# 정확한 파일명이 있으면 그걸로, 없으면 search 키워드로 첫 결과
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
  if [ -z "$url" ]; then echo "  ✗ no url for direct file"; return 1; fi
  curl -sL -A "$UA" -o "$out" "$url"
  echo "  ✓ $(stat -f%z "$out" 2>/dev/null || stat -c%s "$out") bytes"
}

# Fallback: 검색어로 첫 이미지 결과
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
        print(t[5:])  # strip 'File:'
        break
")
  if [ -z "$fn" ]; then echo "  ✗ no search result"; return 1; fi
  echo "  → matched: $fn"
  fetch "$fn" "$out" "$w" || return 1
}

# 시도: 정확 파일명 → 실패시 검색
try() {
  local file="$1"; local out="$2"; local search="$3"; local w="${4:-1280}"
  if ! fetch "$file" "$out" "$w" 2>/dev/null; then
    echo "  retry by search..."
    search_fetch "$search" "$out" "$w" || echo "  ✗✗ both failed: $out"
  fi
}

try "Tatry z Gubałówki.jpg"                      "zakopane-tatra.jpg"        "Tatra Mountains Zakopane panorama"
try "Pomnik Tytusa Chałubińskiego w Zakopanem.jpg" "chalubinski-monument.jpg"  "Pomnik Chałubińskiego Zakopane"
try "Willa Koliba w Zakopanem.jpg"               "willa-koliba.jpg"          "Willa Koliba Zakopane"
try "Willa Pod Jedlami.jpg"                      "willa-pod-jedlami.jpg"     "Willa Pod Jedlami Zakopane"
try "Willa Atma w Zakopanem.jpg"                 "villa-atma.jpg"            "Willa Atma Szymanowski Zakopane"
try "Stanisław Ignacy Witkiewicz - autoportret.jpg" "witkacy-portrait.jpg"   "Stanisław Ignacy Witkiewicz Witkacy"
try "Cmentarz Zasłużonych na Pęksowym Brzyzku.jpg" "peksow-brzyzek.jpg"      "Cmentarz Pęksowy Brzyzek Zakopane"
try "Krupówki w Zakopanem.jpg"                   "krupowki.jpg"              "Krupówki Zakopane street"
try "Morskie Oko 1.jpg"                          "morskie-oko.jpg"           "Morskie Oko Tatry"

ls -la *.jpg 2>/dev/null
