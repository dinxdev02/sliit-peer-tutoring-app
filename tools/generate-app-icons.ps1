param()
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Set-Location (Split-Path $PSScriptRoot -Parent)
function Write-PeerIcon([string]$Path, [int]$Size) {
    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.Clear([System.Drawing.ColorTranslator]::FromHtml('#1E3A8A'))
    $graphics.ScaleTransform($Size / 100.0, $Size / 100.0)
    $white = [System.Drawing.Brushes]::White
    $cap = [System.Drawing.PointF[]]@([System.Drawing.PointF]::new(23,43),[System.Drawing.PointF]::new(50,28),[System.Drawing.PointF]::new(77,43),[System.Drawing.PointF]::new(50,58))
    $base = [System.Drawing.PointF[]]@([System.Drawing.PointF]::new(33,55),[System.Drawing.PointF]::new(50,65),[System.Drawing.PointF]::new(67,55),[System.Drawing.PointF]::new(67,67),[System.Drawing.PointF]::new(50,77),[System.Drawing.PointF]::new(33,67))
    $graphics.FillPolygon($white, $base)
    $graphics.FillPolygon($white, $cap)
    $pen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#F97316'), 4)
    $graphics.DrawLine($pen, 77, 43, 77, 64)
    $graphics.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#F97316'))),74,62,6,6)
    $bitmap.Save((Join-Path (Get-Location) $Path),[System.Drawing.Imaging.ImageFormat]::Png)
    $pen.Dispose(); $graphics.Dispose(); $bitmap.Dispose()
}
Write-PeerIcon 'assets/branding/app-icon.png' 1024
$densitySizes = @{mdpi=48;hdpi=72;xhdpi=96;xxhdpi=144;xxxhdpi=192}
foreach ($density in $densitySizes.Keys) { Write-PeerIcon "android/app/src/main/res/mipmap-$density/ic_launcher.png" $densitySizes[$density] }
$iconSet = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
$contents = Get-Content "$iconSet/Contents.json" -Raw | ConvertFrom-Json
foreach ($entry in $contents.images) {
    if ($entry.filename) {
        $size = [double]($entry.size.Split('x')[0]) * [double]($entry.scale.TrimEnd('x'))
        Write-PeerIcon "$iconSet/$($entry.filename)" ([int]$size)
    }
}
Write-Output 'Generated SLIIT Peer Android and iOS launcher icons.'
