// Genera las versiones del logo y el ícono a partir de logo.svg (salida del vectorizador).
const fs = require("fs");
const path = require("path");

const raiz = path.resolve(__dirname, "..");
const fuente = fs.readFileSync(path.join(raiz, "logo.svg"), "utf8");
const viewBox = fuente.match(/viewBox="([^"]+)"/)[1];
const d = fuente.match(/ d="([^"]+)"/)[1];
const [, , vw, vh] = viewBox.split(" ").map(Number);

const carpeta = path.join(raiz, "logo");
fs.mkdirSync(carpeta, { recursive: true });

const logo = (color) =>
  `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${viewBox}" width="${vw}" height="${vh}"><title>Origen</title><path fill="${color}" fill-rule="evenodd" d="${d}"/></svg>\n`;

fs.writeFileSync(path.join(carpeta, "origen-blanco.svg"), logo("#FFFFFF"));
fs.writeFileSync(path.join(carpeta, "origen-negro.svg"), logo("#0B0A09"));
fs.writeFileSync(path.join(carpeta, "origen-dorado.svg"), logo("#C9A15B"));

// La "O" del logo: subtrazos que caen dentro de la primera letra.
const subtrazos = d.split(/(?=M)/).map((s) => {
  const nums = s.match(/-?\d+(?:\.\d+)?/g).map(Number);
  let maxX = -Infinity, maxY = -Infinity;
  for (let i = 0; i < nums.length; i += 2) { maxX = Math.max(maxX, nums[i]); maxY = Math.max(maxY, nums[i + 1]); }
  return { s, maxX, maxY };
});
const o = subtrazos.filter((t) => t.maxX < 125 && t.maxY < 100);
if (o.length !== 2) throw new Error(`Se esperaban 2 subtrazos para la O y hay ${o.length}`);
const oD = o.map((t) => t.s).join("");
const ancho = Math.max(...o.map((t) => t.maxX)), alto = Math.max(...o.map((t) => t.maxY));
const lado = 172;
const tx = ((lado - ancho) / 2).toFixed(2), ty = ((lado - alto) / 2).toFixed(2);
const icono = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${lado} ${lado}"><rect width="${lado}" height="${lado}" rx="38" fill="#0B0A09"/><path transform="translate(${tx} ${ty})" fill="#C9A15B" fill-rule="evenodd" d="${oD}"/></svg>\n`;
fs.writeFileSync(path.join(carpeta, "icono.svg"), icono);

fs.writeFileSync(path.join(raiz, "herramientas", "logo-datos.json"), JSON.stringify({ viewBox, d, icono }, null, 2));
console.log(`Logo ${vw}×${vh}; ${subtrazos.length} subtrazos; O = ${ancho.toFixed(1)}×${alto.toFixed(1)}`);
