// Inserta el logo vectorizado y el favicon en pagina.html (reemplaza versiones anteriores).
const fs = require("fs");
const path = require("path");

const raiz = path.resolve(__dirname, "..");
const archivo = path.join(raiz, "pagina.html");
const { viewBox, d, icono } = JSON.parse(fs.readFileSync(path.join(__dirname, "logo-datos.json"), "utf8"));
let html = fs.readFileSync(archivo, "utf8");

const simbolo = `<symbol id="i-logo" viewBox="${viewBox}"><path fill="currentColor" fill-rule="evenodd" d="${d}"/></symbol>`;
if (/<symbol id="i-logo"[\s\S]*?<\/symbol>/.test(html)) html = html.replace(/<symbol id="i-logo"[\s\S]*?<\/symbol>/, simbolo);
else html = html.replace("</symbol>\n</svg>", `</symbol>\n  ${simbolo}\n</svg>`);

html = html.replace(/<svg class="logo" viewBox="[^"]*" role="img" aria-label="Origen">[\s\S]*?<\/svg>/g,
  `<svg class="logo" viewBox="${viewBox}" role="img" aria-label="Origen"><use href="#i-logo"/></svg>`);

const favicon = `<link rel="icon" type="image/svg+xml" href="data:image/svg+xml,${encodeURIComponent(icono.trim())}">`;
if (/<link rel="icon"[^>]*>/.test(html)) html = html.replace(/<link rel="icon"[^>]*>/, favicon);
else html = html.replace("<title>Origen 360°</title>", `<title>Origen 360°</title>\n${favicon}`);

fs.writeFileSync(archivo, html);
console.log("Logos en página:", (html.match(/<use href="#i-logo"\/>/g) || []).length);
