# Renderiza el logo original junto al SVG vectorizado (normal y ampliado) para revisarlos.
$ErrorActionPreference = "Stop"
$raiz = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$tmp = Join-Path $env:TEMP "origen-vectorizar"
$svg = [IO.File]::ReadAllText("$raiz\logo.svg")
$orig = "data:image/png;base64," + [Convert]::ToBase64String([IO.File]::ReadAllBytes("$raiz\herramientas\logo-original.png"))
$html = @"
<html><body style="margin:0;background:#0b0a09;color:#fff">
<div style="width:1400px;height:330px;overflow:hidden;position:relative"><img src="$orig" style="position:absolute;width:3072px;left:-835px;top:-760px"></div>
<div style="width:1400px;padding:10px 35px;box-sizing:border-box">$($svg.Replace('<svg ', '<svg style="width:1340px;display:block" '))</div>
<div style="width:1400px;height:420px;overflow:hidden;position:relative">$($svg.Replace('<svg ', '<svg style="position:absolute;width:4000px;left:-1500px;top:-560px" '))</div>
</body></html>
"@
[IO.File]::WriteAllText("$tmp\comparar.html", $html)
$edge = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
Start-Process -FilePath $edge -ArgumentList @("--headless", "--disable-gpu", "--no-first-run", "--user-data-dir=`"$tmp\perfil`"", "--hide-scrollbars", "--window-size=1400,1100", "--screenshot=`"$tmp\comparar.png`"", "file:///$($tmp.Replace('\','/'))/comparar.html") -Wait -NoNewWindow -RedirectStandardError "$tmp\err2.txt"
"$tmp\comparar.png"
