/* =========================================================
   인터랙티브 슬라이드 덱 (시안 B) 컨트롤러
   - → / Space / Click  → 다음 reveal, 마지막이면 다음 슬라이드
   - ← / Backspace      → 이전 reveal, 처음이면 이전 슬라이드
   - Home / End         → 처음 / 끝 슬라이드
   - Esc                → 메인으로
   - 숫자 키 1-9        → 해당 슬라이드로
   ========================================================= */

(function () {
  const slides = Array.from(document.querySelectorAll('.slide'));
  if (!slides.length) return;

  const counterNow = document.querySelector('.counter .now');
  const counterTotal = document.querySelector('.counter .total');
  const progressFill = document.querySelector('.progress-bar .fill');
  const keyhint = document.querySelector('.keyhint');

  let cur = 0;
  let revealStep = 0;

  // 각 슬라이드의 reveal 요소 개수 사전 계산
  const revealCounts = slides.map(s => s.querySelectorAll('.reveal').length);
  // 진도 바를 위한 전역 단계 총합
  const totalSteps = slides.reduce((sum, s, i) => sum + 1 + revealCounts[i], 0);

  function globalStep() {
    let g = 0;
    for (let i = 0; i < cur; i++) g += 1 + revealCounts[i];
    g += revealStep;
    return g;
  }

  function updateUI() {
    if (counterNow) counterNow.textContent = String(cur + 1).padStart(2, '0');
    if (counterTotal) counterTotal.textContent = String(slides.length).padStart(2, '0');
    if (progressFill) {
      const pct = ((globalStep() + 1) / totalSteps) * 100;
      progressFill.style.width = pct + '%';
    }
  }

  function showSlide(idx, fromIdx) {
    if (idx < 0 || idx >= slides.length) return;
    slides.forEach((s, i) => {
      s.classList.remove('active', 'exit-prev', 'exit-next');
      const reveals = s.querySelectorAll('.reveal');
      reveals.forEach(r => r.classList.remove('show'));
    });
    slides[idx].classList.add('active');
    cur = idx;
    revealStep = 0;
    updateUI();
  }

  function nextStep() {
    const reveals = slides[cur].querySelectorAll('.reveal');
    if (revealStep < reveals.length) {
      reveals[revealStep].classList.add('show');
      revealStep++;
      updateUI();
    } else if (cur < slides.length - 1) {
      showSlide(cur + 1, cur);
    }
  }

  function prevStep() {
    if (revealStep > 0) {
      const reveals = slides[cur].querySelectorAll('.reveal');
      revealStep--;
      reveals[revealStep].classList.remove('show');
      updateUI();
    } else if (cur > 0) {
      const prev = cur - 1;
      showSlide(prev, cur);
      // 이전 슬라이드는 모든 reveal을 펼친 상태로 보여주기
      const reveals = slides[prev].querySelectorAll('.reveal');
      reveals.forEach(r => r.classList.add('show'));
      revealStep = reveals.length;
      updateUI();
    }
  }

  // 키보드
  document.addEventListener('keydown', (e) => {
    // 입력 요소에 포커스가 있으면 무시
    if (e.target.matches('input, textarea, select')) return;

    switch (e.key) {
      case 'ArrowRight':
      case ' ':
      case 'Enter':
      case 'PageDown':
        e.preventDefault();
        nextStep();
        break;
      case 'ArrowLeft':
      case 'Backspace':
      case 'PageUp':
        e.preventDefault();
        prevStep();
        break;
      case 'Home':
        e.preventDefault();
        showSlide(0);
        break;
      case 'End':
        e.preventDefault();
        showSlide(slides.length - 1);
        // 마지막 슬라이드는 reveal 다 펼침
        const reveals = slides[slides.length - 1].querySelectorAll('.reveal');
        reveals.forEach(r => r.classList.add('show'));
        revealStep = reveals.length;
        updateUI();
        break;
      case 'Escape':
        location.href = 'index.html';
        break;
      default:
        // 숫자 1-9
        if (/^[1-9]$/.test(e.key)) {
          const target = parseInt(e.key, 10) - 1;
          if (target < slides.length) showSlide(target);
        }
    }
  });

  // 클릭 / 탭으로 다음
  document.querySelector('.deck').addEventListener('click', (e) => {
    if (e.target.closest('a, button, .toggle-tabs, .hotspot, .no-click')) return;
    nextStep();
  });

  // 초기화
  showSlide(0);

  // 키 안내 — 처음 3초 보이고 사라짐
  if (keyhint) {
    keyhint.classList.add('show');
    setTimeout(() => keyhint.classList.remove('show'), 4000);
    // 첫 키 입력 후 다시 한 번 잠깐 보여주기
    let hintShownAgain = false;
    document.addEventListener('keydown', () => {
      if (!hintShownAgain) {
        hintShownAgain = true;
        setTimeout(() => {
          keyhint.classList.add('show');
          setTimeout(() => keyhint.classList.remove('show'), 2000);
        }, 100);
      }
    }, { once: true });
  }

  // 인터랙티브 위젯 — 토글 탭 (학계 합의 vs 한국 인식)
  document.querySelectorAll('.toggle-tabs').forEach(group => {
    const buttons = group.querySelectorAll('button');
    const targetSelector = group.dataset.target;
    const panes = targetSelector ? document.querySelectorAll(targetSelector) : [];
    buttons.forEach((btn, i) => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        buttons.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        panes.forEach((p, pi) => p.style.display = pi === i ? '' : 'none');
      });
    });
    // 초기: 첫 탭 활성
    if (buttons[0]) buttons[0].classList.add('active');
    panes.forEach((p, pi) => { if (pi > 0) p.style.display = 'none'; });
  });

  // 핫스팟 클릭 — 지도 위 점에 정보 표시
  document.querySelectorAll('.hotspot').forEach(h => {
    h.addEventListener('click', (e) => {
      e.stopPropagation();
      const all = h.parentElement.querySelectorAll('.hotspot');
      all.forEach(x => x.classList.remove('active'));
      h.classList.add('active');
      const infoId = h.dataset.info;
      if (infoId) {
        document.querySelectorAll('.hotspot-info').forEach(p => p.style.display = 'none');
        const el = document.getElementById(infoId);
        if (el) el.style.display = '';
      }
    });
  });
})();
