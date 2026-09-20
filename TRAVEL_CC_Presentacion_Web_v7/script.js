const navLinks = [...document.querySelectorAll('nav a')];
const slides = [...document.querySelectorAll('main#slides > section')];
const menuBtn = document.getElementById('menuBtn');
const topbar = document.querySelector('.topbar');
const deck = document.getElementById('slides');
const prevBtn = document.getElementById('prevSlide');
const nextBtn = document.getElementById('nextSlide');
const currentEl = document.getElementById('slideCurrent');
const totalEl = document.getElementById('slideTotal');
const routeStops = document.getElementById('routeStops');
const routeTruck = document.getElementById('routeTruck');
const routeNav = document.getElementById('routeNav');
const cinematicOverlay = document.getElementById('cinematicOverlay');
const cinematicIndex = document.getElementById('cinematicIndex');
const cinematicTitle = document.getElementById('cinematicTitle');

let slideIndex = 0;
let isTravelling = false;
let wheelLock = false;
let presentation = false;

const labels = ['Inicio','Problema','Solución','Arquitectura','Crowdsourcing','Roadmap','Riesgos','Cierre'];
const cinematicLabels = ['INICIO','EL PROBLEMA','SOLUCIÓN','ARQUITECTURA','INTELIGENCIA COLECTIVA','ROADMAP','RIESGOS','CIERRE'];
const shortLabels = ['INICIO','PROBLEMA','SOLUCIÓN','ARQUITECTURA','CROWDSOURCING','ROADMAP','RIESGOS','CIERRE'];
const pad = n => String(n).padStart(2,'0');

totalEl.textContent = pad(slides.length);

// ---------------------------------------------------------
// Strict fullscreen deck: one absolute slide, zero bleed.
// ---------------------------------------------------------
function lockDeckLayout(){
  deck.scrollLeft = 0;
  deck.scrollTop = 0;
  slides.forEach((slide, i) => {
    slide.style.position = 'absolute';
    slide.style.inset = '0';
    slide.style.width = '100vw';
    slide.style.height = '100vh';
    slide.style.maxWidth = 'none';
    slide.style.maxHeight = '100vh';
    slide.style.margin = '0';
    slide.style.boxSizing = 'border-box';
    slide.classList.toggle('active-slide', i === slideIndex);
  });
}

function setOnlyActive(index){
  slides.forEach((s, i) => {
    const active = i === index;
    s.classList.toggle('active-slide', active);
    s.style.visibility = active ? 'visible' : 'hidden';
    s.style.opacity = active ? '1' : '0';
    s.style.zIndex = active ? '20' : '0';
    s.style.pointerEvents = active ? 'auto' : 'none';
  });
}

function buildRoute(){
  routeStops.innerHTML = '';
  slides.forEach((slide, i) => {
    const stop = document.createElement('button');
    stop.className = 'route-stop';
    stop.type = 'button';
    stop.setAttribute('aria-label', `${pad(i+1)}. ${labels[i]}`);
    stop.innerHTML = `<span class="stop-dot"></span><span class="stop-label"><b>${pad(i+1)}.</b> ${shortLabels[i]}</span>`;
    stop.addEventListener('click', () => travelToSlide(i));
    routeStops.appendChild(stop);
  });
}

function updateRoute(){
  [...routeStops.children].forEach((stop, i) => stop.classList.toggle('active', i === slideIndex));
  const pct = slides.length === 1 ? 0 : (slideIndex / (slides.length - 1)) * 100;
  routeTruck.style.left = `${pct}%`;
  routeNav.style.setProperty('--route-progress', `${pct}%`);
}

function updateUI(){
  navLinks.forEach(a => a.classList.toggle('active', a.getAttribute('href') === '#'+slides[slideIndex].id));
  currentEl.textContent = pad(slideIndex + 1);
  prevBtn.disabled = slideIndex === 0;
  nextBtn.disabled = slideIndex === slides.length - 1;
  updateRoute();
}

function directPosition(index){
  if (isTravelling) return;
  slideIndex = Math.max(0, Math.min(index, slides.length - 1));
  slides.forEach(s => {
    s.style.transform = '';
    s.style.filter = '';
  });
  setOnlyActive(slideIndex);
  lockDeckLayout();
  updateUI();
}

function prepareCinematicTitle(target){
  cinematicIndex.textContent = pad(target + 1);
  cinematicTitle.textContent = cinematicLabels[target] || labels[target].toUpperCase();
  cinematicOverlay.setAttribute('aria-label', `Siguiente: ${labels[target]}`);
}

function resetCinematic(){
  if (window.gsap) {
    gsap.set(cinematicOverlay, { opacity: 0, visibility: 'hidden' });
    gsap.set([cinematicTitle, cinematicIndex], { opacity: 0, scale: .94, y: 20, filter: 'blur(0px)' });
    gsap.set('.cinematic-line', { scaleX: 0, opacity: 0 });
  } else {
    cinematicOverlay.style.opacity = '0';
    cinematicOverlay.style.visibility = 'hidden';
  }
  cinematicOverlay.setAttribute('aria-hidden','true');
}

// ---------------------------------------------------------
// Cinematic text overlay transition.
// 1) Blur/fade current slide.
// 2) Giant destination title over blurred background.
// 3) Swap to destination while blurred, then title zooms away
//    with motion blur and the new slide resolves to sharp focus.
// ---------------------------------------------------------
function gsapTravel(index){
  const next = Math.max(0, Math.min(index, slides.length - 1));
  if(next === slideIndex || isTravelling) return;

  isTravelling = true;
  lockDeckLayout();

  const from = slides[slideIndex];
  const to = slides[next];
  const DURATION = 1.80;

  prepareCinematicTitle(next);
  cinematicOverlay.setAttribute('aria-hidden','false');
  cinematicOverlay.style.visibility = 'visible';
  cinematicOverlay.style.pointerEvents = 'none';
  document.body.classList.add('cinematic-active');
  routeTruck.classList.add('driving');

  // Strict single-layer setup: A is the only visible slide until the silent swap at 0.40s.
  slides.forEach((s, i) => {
    gsap.set(s, {
      x:0, y:0, z:0, scale:1, rotationZ:0, rotationY:0,
      opacity:i === slideIndex ? 1 : 0,
      visibility:i === slideIndex ? 'visible' : 'hidden',
      zIndex:i === slideIndex ? 30 : 0,
      pointerEvents:i === slideIndex ? 'auto' : 'none',
      filter:'none'
    });
  });

  gsap.set(cinematicOverlay, { opacity:0, visibility:'visible' });
  gsap.set(cinematicTitle, { opacity:0, scale:.92, y:18, filter:'blur(0px)', transformOrigin:'50% 50%' });
  gsap.set(cinematicIndex, { opacity:0, scale:.94, y:14, filter:'blur(0px)' });
  gsap.set('.cinematic-line', { scaleX:0, opacity:0, transformOrigin:'50% 50%' });

  const tl = gsap.timeline({
    defaults:{ overwrite:'auto' },
    onComplete:finish
  });

  // =========================================================
  // EXACT CINEMATIC TIMELINE
  // 0.0 -> 0.4  COVER: A blurs/fades + giant destination title appears.
  // 0.4         SILENT SWAP: A hidden, B becomes visible already blurred.
  // 0.4 -> 1.2 HOLD: title remains fully readable over blurred B.
  // 1.2 -> 1.8 REVEAL: title dissolves while B unblurs to sharp.
  // =========================================================

  // PHASE 1 — Cover current slide and establish readable title.
  tl.to(from, {
      duration:.40,
      scale:.985,
      filter:'blur(20px) brightness(.72) saturate(.7)',
      opacity:.16,
      ease:'power2.inOut'
    }, 0)
    .to(cinematicOverlay, {
      duration:.28,
      opacity:1,
      ease:'power2.out'
    }, 0.02)
    .to(cinematicIndex, {
      duration:.30,
      opacity:1,
      scale:1,
      y:0,
      filter:'blur(0px)',
      ease:'power3.out'
    }, 0.08)
    .to(cinematicTitle, {
      duration:.32,
      opacity:1,
      scale:1,
      y:0,
      filter:'blur(0px)',
      ease:'power3.out'
    }, 0.08)
    .to('.cinematic-line', {
      duration:.28,
      scaleX:1,
      opacity:.9,
      ease:'power2.out'
    }, 0.12)

    // PHASE 2 — SILENT SWAP exactly at 0.40s.
    .set(to, {
      visibility:'visible',
      opacity:1,
      scale:1.018,
      filter:'blur(20px) brightness(.82) saturate(.8)',
      zIndex:30,
      pointerEvents:'none'
    }, 0.40)
    .set(from, {
      visibility:'hidden',
      display:'none',
      opacity:0,
      filter:'none',
      scale:1,
      zIndex:0,
      pointerEvents:'none'
    }, 0.40)

    // PHASE 2 HOLD — no slide/title movement from 0.40s to 1.20s.
    .to({}, { duration:.80 }, 0.40)

    // PHASE 3 — title dissolves + destination resolves together from 1.20 to 1.80.
    .to(cinematicTitle, {
      duration:.60,
      opacity:0,
      scale:1.08,
      y:-2,
      filter:'blur(10px)',
      ease:'power2.inOut'
    }, 1.20)
    .to(cinematicIndex, {
      duration:.48,
      opacity:0,
      scale:1.06,
      y:-2,
      filter:'blur(7px)',
      ease:'power2.inOut'
    }, 1.20)
    .to('.cinematic-line', {
      duration:.42,
      opacity:0,
      scaleX:1.08,
      ease:'power2.in'
    }, 1.20)
    .to(to, {
      duration:.60,
      opacity:1,
      scale:1,
      filter:'blur(0px) brightness(1) saturate(1)',
      ease:'power3.out'
    }, 1.20)
    .to(cinematicOverlay, {
      duration:.60,
      opacity:0,
      ease:'power2.inOut'
    }, 1.20);

  function finish(){
    slideIndex = next;
    setOnlyActive(slideIndex);
    slides.forEach(s => {
      gsap.set(s, { clearProps:'x,y,z,scale,rotationZ,rotationY,filter,opacity,visibility,display' });
    });
    setOnlyActive(slideIndex);
    resetCinematic();
    routeTruck.classList.remove('driving');
    document.body.classList.remove('cinematic-active');
    updateUI();
    deck.scrollLeft = 0;
    deck.scrollTop = 0;
    isTravelling = false;
  }
}

function cssTravel(index){
  const next = Math.max(0, Math.min(index, slides.length - 1));
  if(next === slideIndex || isTravelling) return;

  isTravelling = true;
  const from = slides[slideIndex];
  const to = slides[next];
  prepareCinematicTitle(next);
  cinematicOverlay.style.visibility = 'visible';
  cinematicOverlay.style.opacity = '0';
  document.body.classList.add('cinematic-active');
  routeTruck.classList.add('driving');

  // PHASE 1: 0.0 -> 0.4 — blur/fade A + title in.
  from.style.transition = 'filter .40s cubic-bezier(.65,0,.35,1), opacity .40s cubic-bezier(.65,0,.35,1), transform .40s cubic-bezier(.65,0,.35,1)';
  from.style.filter = 'blur(20px) brightness(.72) saturate(.7)';
  from.style.opacity = '.16';
  from.style.transform = 'scale(.985)';

  cinematicOverlay.style.transition = 'opacity .28s ease-out';
  cinematicTitle.style.transition = 'opacity .32s cubic-bezier(.16,1,.3,1), transform .32s cubic-bezier(.16,1,.3,1), filter .32s ease-out';
  cinematicIndex.style.transition = 'opacity .30s cubic-bezier(.16,1,.3,1), transform .30s cubic-bezier(.16,1,.3,1)';
  cinematicTitle.style.opacity = '0';
  cinematicTitle.style.transform = 'scale(.92) translateY(18px)';
  cinematicIndex.style.opacity = '0';
  cinematicIndex.style.transform = 'scale(.94) translateY(14px)';

  requestAnimationFrame(() => {
    cinematicOverlay.style.opacity = '1';
    cinematicTitle.style.opacity = '1';
    cinematicTitle.style.transform = 'scale(1) translateY(0)';
    cinematicIndex.style.opacity = '1';
    cinematicIndex.style.transform = 'scale(1) translateY(0)';
  });

  setTimeout(() => {
    // PHASE 2: exact 0.4s silent swap. B is already blurred behind the title.
    from.style.display = 'none';
    from.style.visibility = 'hidden';
    from.style.opacity = '0';
    from.style.filter = 'none';
    from.style.transform = 'none';

    to.style.display = 'block';
    to.style.visibility = 'visible';
    to.style.opacity = '1';
    to.style.filter = 'blur(20px) brightness(.82) saturate(.8)';
    to.style.transform = 'scale(1.018)';
    to.style.transition = 'none';

    // PHASE 2 HOLD: 0.4 -> 1.2, deliberately untouched for reading.
    setTimeout(() => {
      // PHASE 3: 1.2 -> 1.8 — title fades while B unblurs.
      cinematicTitle.style.transition = 'opacity .60s cubic-bezier(.65,0,.35,1), transform .60s cubic-bezier(.65,0,.35,1), filter .60s cubic-bezier(.65,0,.35,1)';
      cinematicIndex.style.transition = 'opacity .48s ease-in-out, transform .48s ease-in-out, filter .48s ease-in-out';
      cinematicTitle.style.opacity = '0';
      cinematicTitle.style.transform = 'scale(1.08) translateY(-2px)';
      cinematicTitle.style.filter = 'blur(10px)';
      cinematicIndex.style.opacity = '0';
      cinematicIndex.style.transform = 'scale(1.06) translateY(-2px)';
      cinematicIndex.style.filter = 'blur(7px)';

      to.style.transition = 'filter .60s cubic-bezier(.16,1,.3,1), transform .60s cubic-bezier(.16,1,.3,1)';
      requestAnimationFrame(() => {
        to.style.filter = 'blur(0px) brightness(1) saturate(1)';
        to.style.transform = 'scale(1)';
      });

      cinematicOverlay.style.transition = 'opacity .60s cubic-bezier(.65,0,.35,1)';
      cinematicOverlay.style.opacity = '0';

      setTimeout(() => {
        slideIndex = next;
        setOnlyActive(slideIndex);
        slides.forEach(s => {
          s.style.transition='';
          s.style.transform='';
          s.style.filter='';
          s.style.display='';
        });
        resetCinematic();
        routeTruck.classList.remove('driving');
        document.body.classList.remove('cinematic-active');
        updateUI();
        isTravelling = false;
      }, 600);
    }, 800);
  }, 400);
}

function travelToSlide(index){
  if(isTravelling || index < 0 || index >= slides.length || index === slideIndex) return;
  if(window.gsap) gsapTravel(index); else cssTravel(index);
}

prevBtn.addEventListener('click', () => travelToSlide(slideIndex - 1));
nextBtn.addEventListener('click', () => travelToSlide(slideIndex + 1));

menuBtn.addEventListener('click',()=>topbar.classList.toggle('mobile'));
navLinks.forEach(a=>a.addEventListener('click',(e)=>{
  e.preventDefault();
  const target = slides.findIndex(s => '#'+s.id === a.getAttribute('href'));
  if(target >= 0) travelToSlide(target);
  topbar.classList.remove('mobile');
}));

const heroExplore = document.querySelector('.hero-actions a[href="#problema"]');
heroExplore?.addEventListener('click', e => {
  e.preventDefault();
  travelToSlide(1);
});

const score = document.getElementById('scoreValue');
const meter = document.getElementById('meter');
document.getElementById('simulate').addEventListener('click', ()=>{
  let value = 52;
  const timer = setInterval(()=>{
    value += Math.floor(Math.random()*8)+3;
    if(value >= 86){value=86; clearInterval(timer)}
    score.textContent = value;
    meter.style.width = value + '%';
  },100);
});

const presentationBtn = document.getElementById('presentationMode');
presentationBtn.addEventListener('click',()=>{
  presentation = !presentation;
  document.body.classList.toggle('presentation', presentation);
  presentationBtn.textContent = presentation ? 'Salir de presentación' : 'Modo presentación';
});

document.addEventListener('keydown',(e)=>{
  if(['ArrowRight','ArrowDown','PageDown',' '].includes(e.key)){
    e.preventDefault();
    if(slideIndex < slides.length-1) travelToSlide(slideIndex+1);
  }
  if(['ArrowLeft','ArrowUp','PageUp'].includes(e.key)){
    e.preventDefault();
    if(slideIndex > 0) travelToSlide(slideIndex-1);
  }
  if(e.key==='Escape' && presentation){
    presentation=false;
    document.body.classList.remove('presentation');
    presentationBtn.textContent='Modo presentación';
  }
});

deck.addEventListener('wheel',(e)=>{
  if(Math.abs(e.deltaY) <= Math.abs(e.deltaX) || wheelLock || isTravelling) return;
  wheelLock = true;
  const target = slideIndex + (e.deltaY > 0 ? 1 : -1);
  if(target >= 0 && target < slides.length) travelToSlide(target);
  setTimeout(()=>wheelLock=false,1400);
},{passive:true});

window.addEventListener('resize',()=>{
  if(!isTravelling){
    lockDeckLayout();
    updateUI();
  }
});

lockDeckLayout();
buildRoute();
setOnlyActive(slideIndex);
updateUI();
resetCinematic();
