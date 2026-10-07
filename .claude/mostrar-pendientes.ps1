$ruta = Join-Path (Split-Path -Parent $PSScriptRoot) 'CLAUDE.md'
$t = Get-Content -Raw -Encoding UTF8 -LiteralPath $ruta
$i = $t.IndexOf('## Pendiente')
if ($i -ge 0) {
    Write-Output 'PENDIENTES DEL PROYECTO. Muestralos primero al usuario al iniciar la sesion, antes de cualquier otra cosa, y pregunta por cual quiere empezar. No ejecutes nada sin su confirmacion.'
    Write-Output $t.Substring($i)
}
