# Genera los PNG: logos con fondo transparente, íconos e imagen para compartir.
$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$tmp = Join-Path $env:TEMP "origen-vectorizar"
$edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$sitio = Join-Path $raiz "sitio"
New-Item -ItemType Directory -Force $tmp, $sitio | Out-Null
Add-Type -AssemblyName System.Drawing

$datos = Get-Content (Join-Path $raiz "herramientas\logo-datos.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$vb = $datos.viewBox.Split(" ") | ForEach-Object { [double]$_ }

function Captura([string]$html, [string]$png, [int]$w, [int]$h, [switch]$transparente) {
  $archivo = Join-Path $tmp ("captura-" + [IO.Path]::GetFileNameWithoutExtension($png) + ".html")
  [IO.File]::WriteAllText($archivo, $html, (New-Object Text.UTF8Encoding $false))
  $argumentos = @("--headless", "--disable-gpu", "--no-first-run", "--hide-scrollbars", "--user-data-dir=`"$tmp\perfil`"",
    "--force-device-scale-factor=1", "--window-size=$w,$h", "--virtual-time-budget=8000", "--screenshot=`"$png`"")
  if ($transparente) { $argumentos += "--default-background-color=00000000" }
  $argumentos += ([Uri]$archivo).AbsoluteUri
  Start-Process -FilePath $edge -ArgumentList $argumentos -Wait -NoNewWindow -RedirectStandardError (Join-Path $tmp "err-captura.txt")
  $img = [Drawing.Image]::FromFile($png)
  "{0}  {1}x{2}" -f (Split-Path $png -Leaf), $img.Width, $img.Height
  $img.Dispose()
}

# Logos transparentes a 2400 px de ancho
$ancho = 2400
$alto = [int][math]::Ceiling($ancho * $vb[3] / $vb[2])
foreach ($v in @(@("blanco", "#FFFFFF"), @("negro", "#0B0A09"), @("dorado", "#C9A15B"))) {
  $html = "<html><body style=`"margin:0;background:transparent`"><svg viewBox=`"$($datos.viewBox)`" style=`"display:block;width:${ancho}px;height:${alto}px`"><path fill=`"$($v[1])`" fill-rule=`"evenodd`" d=`"$($datos.d)`"/></svg></body></html>"
  Captura $html (Join-Path $raiz "logo\origen-$($v[0]).png") $ancho $alto -transparente
}

# Íconos
foreach ($t in @(@(512, (Join-Path $raiz "logo\icono-512.png")), @(180, (Join-Path $sitio "apple-touch-icon.png")))) {
  $svg = $datos.icono.Replace("<svg ", "<svg style=`"display:block;width:$($t[0])px;height:$($t[0])px`" ")
  Captura "<html><body style=`"margin:0;background:transparent`">$svg</body></html>" $t[1] $t[0] $t[0] -transparente
}
[IO.File]::WriteAllText((Join-Path $sitio "favicon.svg"), $datos.icono, (New-Object Text.UTF8Encoding $false))

# Imagen para compartir (WhatsApp, Facebook)
$plantilla = [IO.File]::ReadAllText((Join-Path $raiz "herramientas\compartir.html"), [Text.Encoding]::UTF8)
$html = $plantilla.Replace("__VIEWBOX__", $datos.viewBox).Replace("__LOGO_D__", $datos.d)
Captura $html (Join-Path $sitio "compartir.png") 1200 630
