param(
  [Parameter(Mandatory = $true)][string]$Imagen,
  [Parameter(Mandatory = $true)][string]$Salida
)
# Vectoriza un logo con Edge en modo headless usando vectorizar.html.
$ErrorActionPreference = "Stop"
$edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$aqui = Split-Path -Parent $MyInvocation.MyCommand.Path
$tmp = Join-Path $env:TEMP "origen-vectorizar"
New-Item -ItemType Directory -Force $tmp | Out-Null

$ext = [IO.Path]::GetExtension($Imagen).TrimStart(".").ToLower()
if ($ext -eq "jpg") { $ext = "jpeg" }
$datos = "data:image/$ext;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path $Imagen)))
$plantilla = [IO.File]::ReadAllText((Join-Path $aqui "vectorizar.html"), [Text.Encoding]::UTF8)
$pagina = Join-Path $tmp "vectorizar.html"
[IO.File]::WriteAllText($pagina, $plantilla.Replace("__IMAGEN__", $datos), (New-Object Text.UTF8Encoding $false))

$volcado = Join-Path $tmp "dom.html"
$argumentos = @("--headless", "--disable-gpu", "--no-first-run", "--user-data-dir=`"$tmp\perfil`"", "--virtual-time-budget=60000", "--dump-dom", ("file:///" + $pagina.Replace("\", "/")))
Start-Process -FilePath $edge -ArgumentList $argumentos -RedirectStandardOutput $volcado -RedirectStandardError (Join-Path $tmp "err.txt") -Wait -NoNewWindow
$dom = [IO.File]::ReadAllText($volcado, [Text.Encoding]::UTF8)
$m = [regex]::Match($dom, '<pre id="salida">([\s\S]*?)</pre>')
if (-not $m.Success) { throw "Edge no devolvió resultado." }
$svg = [Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
if ($svg -notlike "<svg*") { throw $svg }
[IO.File]::WriteAllText($Salida, $svg, (New-Object Text.UTF8Encoding $false))
"SVG: $Salida ($([math]::Round($svg.Length / 1KB, 1)) KB)"
