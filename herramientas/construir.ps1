# Arma sitio\index.html a partir de pagina.html (la misma página que se publica como vista previa).
param([string]$Dominio = "")
$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$sitio = Join-Path $raiz "sitio"
New-Item -ItemType Directory -Force $sitio | Out-Null

$src = [IO.File]::ReadAllText((Join-Path $raiz "pagina.html"), [Text.Encoding]::UTF8)
$partes = $src -split '<!-- /cabeza -->', 2
if ($partes.Count -ne 2) { throw "Falta el marcador <!-- /cabeza --> en pagina.html" }

# Facebook y WhatsApp necesitan la dirección completa de la imagen; con dominio se usa absoluta.
$base = if ($Dominio) { "https://$($Dominio.TrimEnd('/'))/" } else { "" }
$extra = @"
<link rel="icon" type="image/svg+xml" href="favicon.svg">
<link rel="apple-touch-icon" href="apple-touch-icon.png">
<meta property="og:type" content="website">
<meta property="og:locale" content="es_MX">
<meta property="og:image" content="${base}compartir.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta name="twitter:card" content="summary_large_image">
<meta name="theme-color" content="#0B0A09">
"@
if ($Dominio) { $extra += "`n<link rel=`"canonical`" href=`"$base`">`n<meta property=`"og:url`" content=`"$base`">" }

$cabeza = [regex]::Replace($partes[0].Trim(), '<link rel="icon"[^>]*>\r?\n?', '')
$html = "<!doctype html>`n<html lang=`"es-MX`">`n<head>`n<meta charset=`"utf-8`">`n<meta name=`"viewport`" content=`"width=device-width, initial-scale=1`">`n$cabeza`n$extra`n</head>`n<body>`n$($partes[1].Trim())`n</body>`n</html>`n"
[IO.File]::WriteAllText((Join-Path $sitio "index.html"), $html, (New-Object Text.UTF8Encoding $false))
if ($Dominio) { [IO.File]::WriteAllText((Join-Path $sitio "CNAME"), $Dominio.Trim(), (New-Object Text.UTF8Encoding $false)) }
Get-ChildItem $sitio | Select-Object Name, Length
