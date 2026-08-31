# Gera os ícones do app (Windows .ico, Android mipmaps, iOS AppIcon)
# a partir do símbolo branco em fundo transparente (img/Somentelogo.png),
# sobre o fundo roxo primário do tema (#6C2BD9).
# Uso: powershell -ExecutionPolicy Bypass -File tool/generate_icons.ps1

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$src = [System.Drawing.Image]::FromFile("$root\img\Somentelogo.png")
$bg = [System.Drawing.Color]::FromArgb(255, 0x6C, 0x2B, 0xD9)

function New-IconBitmap([int]$size) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear($bg)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  # Símbolo ocupa ~62% do canvas, centrado e mantendo a proporção 124:104.
  $side = [int]($size * 0.62)
  $w = $side
  $h = [int]($side * 104 / 124)
  if ($h -gt $side) { $h = $side; $w = [int]($side * 124 / 104) }
  $x = [int](($size - $w) / 2)
  $y = [int](($size - $h) / 2)
  $g.DrawImage($src, $x, $y, $w, $h)
  $g.Dispose()
  return $bmp
}

function Get-PngBytes([System.Drawing.Bitmap]$bmp) {
  $ms = New-Object System.IO.MemoryStream
  $bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
  $bytes = $ms.ToArray()
  $ms.Dispose()
  return , $bytes
}

# --- Android (mipmaps) ---
$android = @{
  'mipmap-mdpi' = 48; 'mipmap-hdpi' = 72; 'mipmap-xhdpi' = 96
  'mipmap-xxhdpi' = 144; 'mipmap-xxxhdpi' = 192
}
foreach ($k in $android.Keys) {
  $b = New-IconBitmap $android[$k]
  $b.Save("$root\android\app\src\main\res\$k\ic_launcher.png",
    [System.Drawing.Imaging.ImageFormat]::Png)
  $b.Dispose()
  Write-Host "android $k ok"
}

# --- iOS (AppIcon.appiconset) ---
$ios = @{
  'Icon-App-20x20@1x.png' = 20; 'Icon-App-20x20@2x.png' = 40
  'Icon-App-20x20@3x.png' = 60; 'Icon-App-29x29@1x.png' = 29
  'Icon-App-29x29@2x.png' = 58; 'Icon-App-29x29@3x.png' = 87
  'Icon-App-40x40@1x.png' = 40; 'Icon-App-40x40@2x.png' = 80
  'Icon-App-40x40@3x.png' = 120; 'Icon-App-60x60@2x.png' = 120
  'Icon-App-60x60@3x.png' = 180; 'Icon-App-76x76@1x.png' = 76
  'Icon-App-76x76@2x.png' = 152; 'Icon-App-83.5x83.5@2x.png' = 167
  'Icon-App-1024x1024@1x.png' = 1024
}
foreach ($k in $ios.Keys) {
  $b = New-IconBitmap $ios[$k]
  $b.Save("$root\ios\Runner\Assets.xcassets\AppIcon.appiconset\$k",
    [System.Drawing.Imaging.ImageFormat]::Png)
  $b.Dispose()
  Write-Host "ios $k ok"
}

# --- Windows (.ico DIB clássico, compatível com o RC: 16, 32, 48, 256) ---
function Get-IcoDibBytes([System.Drawing.Bitmap]$bmp) {
  $s = $bmp.Width
  $ms = New-Object System.IO.MemoryStream
  $bw = New-Object System.IO.BinaryWriter $ms
  # BITMAPINFOHEADER (altura dobrada: XOR + máscara AND)
  $bw.Write([UInt32]40)
  $bw.Write([Int32]$s)
  $bw.Write([Int32]($s * 2))
  $bw.Write([UInt16]1)
  $bw.Write([UInt16]32)
  $bw.Write([UInt32]0)
  $bw.Write([UInt32]0)
  $bw.Write([Int32]0); $bw.Write([Int32]0)
  $bw.Write([UInt32]0); $bw.Write([UInt32]0)
  # Pixels BGRA de baixo para cima
  for ($y = $s - 1; $y -ge 0; $y--) {
    for ($x = 0; $x -lt $s; $x++) {
      $p = $bmp.GetPixel($x, $y)
      $bw.Write([Byte]$p.B); $bw.Write([Byte]$p.G)
      $bw.Write([Byte]$p.R); $bw.Write([Byte]$p.A)
    }
  }
  # Máscara AND zerada (transparência vem do alpha), linhas em pad de 4 bytes
  $rowBytes = [int]([math]::Ceiling($s / 32)) * 4
  $bw.Write((New-Object byte[] ($rowBytes * $s)))
  $bw.Flush()
  $bytes = $ms.ToArray()
  $bw.Dispose(); $ms.Dispose()
  return , $bytes
}

$sizes = @(16, 32, 48, 256)
$dibs = New-Object System.Collections.Generic.List[object]
foreach ($s in $sizes) {
  $b = New-IconBitmap $s
  $dibs.Add((Get-IcoDibBytes $b))
  $b.Dispose()
}
$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms
$bw.Write([UInt16]0)
$bw.Write([UInt16]1)
$bw.Write([UInt16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
  $s = $sizes[$i]
  $dim = if ($s -ge 256) { 0 } else { $s }
  $bw.Write([Byte]$dim)
  $bw.Write([Byte]$dim)
  $bw.Write([Byte]0)
  $bw.Write([Byte]0)
  $bw.Write([UInt16]1)
  $bw.Write([UInt16]32)
  $bw.Write([UInt32]([byte[]]$dibs[$i]).Length)
  $bw.Write([UInt32]$offset)
  $offset += ([byte[]]$dibs[$i]).Length
}
for ($i = 0; $i -lt $sizes.Count; $i++) {
  $bw.Write([byte[]]$dibs[$i])
}
$bw.Flush()
$out = "$root\windows\runner\resources\app_icon.ico"
[System.IO.File]::WriteAllBytes($out, $ms.ToArray())
$bw.Dispose()
$ms.Dispose()
Write-Host "windows app_icon.ico ok"

$src.Dispose()
Write-Host "Icones gerados com sucesso."
