# Prepara os videos do fundo da home: tira o audio, recorta no formato certo, comprime e salva um quadro (poster).
# Originais em videos\originais (fora do git). Resultado em videos\<nome>-<versao>.mp4 e .jpg
#   versao pc  = deitado 1280x720 (computador)
#   versao cel = em pe 720x1280 (celular)
#   foco = onde o recorte fica quando o original tem outro formato: 0 = esquerda/topo, 0.5 = centro, 1 = direita/base
# Uso: powershell -ExecutionPolicy Bypass -File videos\preparar-videos.ps1
# A ordem e as legendas do fundo ficam na lista VIDEOS do index.html.
$ff = 'I:\ferramentas-claude\ffmpeg.exe'
$pasta = $PSScriptRoot
$lista = @(
  # original          nome      versao  foco
  @('doce.mp4',       'doce',       'pc',  '0.5'),
  @('gateau.mp4',     'gateau',     'cel', '0.5'),
  @('vinho.mp4',      'vinho',      'pc',  '0.43'),
  @('vinho.mp4',      'vinho',      'cel', '0.5'),
  @('cheesecake.mp4', 'cheesecake', 'pc',  '0.5'),
  @('cheesecake.mp4', 'cheesecake', 'cel', '0.5'),
  @('fondue.mp4',     'fondue',     'pc',  '0.5'),
  @('fondue.mp4',     'fondue',     'cel', '0.54')
)
foreach ($v in $lista) {
  $orig, $nome, $tipo, $foco = $v
  if ($tipo -eq 'pc') { $w = 1280; $h = 720 } else { $w = 720; $h = 1280 }
  $crop = "crop='trunc(min(iw,ih*$w/$h)/2)*2':'trunc(min(ih,iw*$h/$w)/2)*2':'(iw-ow)*$foco':'(ih-oh)*$foco'"
  $saida = Join-Path $pasta "$nome-$tipo"
  & $ff -hide_banner -loglevel error -y -i (Join-Path $pasta "originais\$orig") -vf "$crop,scale=${w}:${h}:flags=lanczos,setsar=1" -an -c:v libx264 -preset slow -crf 26 -profile:v high -pix_fmt yuv420p -g 48 -movflags +faststart "$saida.mp4"
  & $ff -hide_banner -loglevel error -y -i "$saida.mp4" -frames:v 1 -q:v 5 "$saida.jpg"
  '{0}-{1}.mp4  {2:N2} MB' -f $nome, $tipo, ((Get-Item "$saida.mp4").Length / 1MB)
}
