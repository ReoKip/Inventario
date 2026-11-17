// Genera los íconos de la app (PNG) en res/. Uso: node tools/icons.js
const {chromium}=require('playwright');const path=require('path');const fs=require('fs');
const BOX='<path d="M3 7.5 12 3l9 4.5v9L12 21l-9-4.5v-9Z"/><path d="M3 7.5 12 12l9-4.5M12 12v9"/>';
const GRAD='<linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#ff8361"/><stop offset=".55" stop-color="#e0507a"/><stop offset="1" stop-color="#7652d2"/></linearGradient>';
const glyph=(scale)=>`<g transform="translate(${54-12*scale} ${54-12*scale}) scale(${scale})" fill="none" stroke="#fff" stroke-width="${1.7}" stroke-linejoin="round" stroke-linecap="round">${BOX}</g>`;
const svgs={
  legacy:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${GRAD}</defs><rect x="4" y="4" width="100" height="100" rx="26" fill="url(#g)"/>${glyph(2.6)}</svg>`,
  bg:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${GRAD}</defs><rect width="108" height="108" fill="url(#g)"/></svg>`,
  fg:`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108">${glyph(1.9)}</svg>`};
(async()=>{const b=await chromium.launch();const p=await b.newPage();
const shot=async(svg,size,file)=>{await p.setViewportSize({width:size,height:size});await p.setContent(`<html><body style="margin:0;background:transparent">${svg.replace('<svg ',`<svg width="${size}" height="${size}" `)}</body></html>`);
 fs.mkdirSync(path.dirname(file),{recursive:true});await p.screenshot({path:file,omitBackground:true});};
for(const [d,s] of [["mdpi",48],["hdpi",72],["xhdpi",96],["xxhdpi",144],["xxxhdpi",192]]) await shot(svgs.legacy,s,`res/mipmap-${d}/ic_launcher.png`);
await shot(svgs.bg,432,"res/drawable-xxxhdpi/ic_launcher_bg.png");await shot(svgs.fg,432,"res/drawable-xxxhdpi/ic_launcher_fg.png");
// Íconos de la app web (iPhone y navegadores): cuadrados sin bordes; el sistema redondea las esquinas.
const full=`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${GRAD}</defs><rect width="108" height="108" fill="url(#g)"/>${glyph(2.4)}</svg>`;
const mask=`<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 108"><defs>${GRAD}</defs><rect width="108" height="108" fill="url(#g)"/>${glyph(1.9)}</svg>`;
await shot(full,180,"../icons/apple-touch-icon.png");await shot(full,192,"../icons/icon-192.png");await shot(full,512,"../icons/icon-512.png");await shot(mask,512,"../icons/icon-maskable-512.png");await b.close();})();
