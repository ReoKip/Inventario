// Genera los íconos de la app (PNG). Uso: node tools/icons.js   (desde la carpeta android/)
//   Versión normal: res/ (Android) e ../icons/ (web).
//   Versión de prueba: res-beta/ (Android) e ../icons-beta/ (web), en azul y con la palabra BETA.
const {chromium}=require('playwright');const path=require('path');const fs=require('fs');
// Logo de Stok: tres cajas apiladas.
const BOX='<rect x="3" y="12.5" width="8.5" height="8.5" rx="1.8"/><rect x="12.5" y="12.5" width="8.5" height="8.5" rx="1.8"/><rect x="7.75" y="3" width="8.5" height="8.5" rx="1.8"/><path d="M7.25 12.5v2.6M16.75 12.5v2.6M12 3v2.6"/>';
const VARIANTS={
  stable:{stops:["#ff8361","#e0507a","#7652d2"],res:"res",web:"../icons",label:false},
  beta:{stops:["#38bdf8","#2563eb","#4338ca"],res:"res-beta",web:"../icons-beta",label:true}
};
const grad=v=>`<linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="${v.stops[0]}"/><stop offset=".55" stop-color="${v.stops[1]}"/><stop offset="1" stop-color="${v.stops[2]}"/></linearGradient>`;
// dy: cuánto sube el logo para dejar espacio a la palabra BETA.
const glyph=(scale,dy=0)=>`<g transform="translate(${54-12*scale} ${54-12*scale-dy}) scale(${scale})" fill="none" stroke="#fff" stroke-width="1.6" stroke-linejoin="round" stroke-linecap="round">${BOX}</g>`;
const tag=(y,size)=>`<text x="54" y="${y}" text-anchor="middle" font-family="DejaVu Sans, Arial, sans-serif" font-weight="700" font-size="${size}" letter-spacing="${size*0.12}" fill="#fff">BETA</text>`;
function svgs(v){
  const L=v.label, G=grad(v);
  return {
    legacy:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${G}</defs><rect x="4" y="4" width="100" height="100" rx="26" fill="url(#g)"/>${glyph(L?2.6:3.1,L?9:0)}${L?tag(92,13):""}</svg>`,
    bg:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${G}</defs><rect width="108" height="108" fill="url(#g)"/></svg>`,
    fg:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">${glyph(L?1.9:2.3,L?6:0)}${L?tag(80,9):""}</svg>`,
    full:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${G}</defs><rect width="108" height="108" fill="url(#g)"/>${glyph(L?2.6:3.1,L?9:0)}${L?tag(95,13):""}</svg>`,
    mask:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${G}</defs><rect width="108" height="108" fill="url(#g)"/>${glyph(L?2.1:2.5,L?7:0)}${L?tag(84,10):""}</svg>`
  };
}
(async()=>{const b=await chromium.launch();const p=await b.newPage();
const shot=async(svg,size,file)=>{await p.setViewportSize({width:size,height:size});await p.setContent(`<html><body style="margin:0;background:transparent">${svg.replace('<svg ',`<svg width="${size}" height="${size}" `)}</body></html>`);
 fs.mkdirSync(path.dirname(file),{recursive:true});await p.screenshot({path:file,omitBackground:true});};
for(const v of Object.values(VARIANTS)){
  const s=svgs(v);
  for(const [d,px] of [["mdpi",48],["hdpi",72],["xhdpi",96],["xxhdpi",144],["xxxhdpi",192]]) await shot(s.legacy,px,`${v.res}/mipmap-${d}/ic_launcher.png`);
  await shot(s.bg,432,`${v.res}/drawable-xxxhdpi/ic_launcher_bg.png`);await shot(s.fg,432,`${v.res}/drawable-xxxhdpi/ic_launcher_fg.png`);
  // Íconos web (iPhone y navegadores): cuadrados sin bordes; el sistema redondea las esquinas.
  await shot(s.full,180,`${v.web}/apple-touch-icon.png`);await shot(s.full,192,`${v.web}/icon-192.png`);await shot(s.full,512,`${v.web}/icon-512.png`);await shot(s.mask,512,`${v.web}/icon-maskable-512.png`);
}
await b.close();})();
