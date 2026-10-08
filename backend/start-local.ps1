param([string]$Device = 'emulator-5554', [switch]$Verify)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$firebaseCommand = (Get-Command firebase.cmd).Source
$runtimeInfo = Join-Path (Split-Path $firebaseCommand -Parent) 'node_modules/firebase-tools/lib/emulator/downloadableEmulatorInfo.json'
$env:FIREBASE_EMULATORS_PATH = Join-Path (Get-Location) '.tmp-tools/emulators'
& node.exe backend/download-runtime.cjs $runtimeInfo
if ($LASTEXITCODE -ne 0) { throw 'Firebase runtime download failed. Run this command again to resume.' }
$ui = (Get-Content $runtimeInfo -Raw | ConvertFrom-Json).ui.main
$uiFolder = Join-Path $env:FIREBASE_EMULATORS_PATH ('ui-v' + $ui.version)
if (-not (Test-Path (Join-Path $uiFolder 'server/server.mjs'))) {
    Expand-Archive -LiteralPath (Join-Path $env:FIREBASE_EMULATORS_PATH $ui.downloadPathRelativeToCacheDir) -DestinationPath $uiFolder -Force
}
$ports = @(9099, 8080, 9199)
$listening = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LocalPort)
if (@($ports | Where-Object { $_ -notin $listening }).Count -eq 3) {
    $arguments = @('emulators:start', '--only', 'auth,firestore,storage', '--project', 'demo-sliit-peer', '--export-on-exit', 'emulator-data')
    if (Test-Path 'emulator-data/firebase-export-metadata.json') { $arguments += @('--import', 'emulator-data') }
    $cli = Join-Path (Split-Path $firebaseCommand -Parent) 'node_modules/firebase-tools/lib/bin/firebase.js'
    Start-Process -FilePath (Get-Command node.exe).Source -ArgumentList (@('"' + $cli + '"') + $arguments) -WindowStyle Hidden -RedirectStandardOutput '.tmp-tools/backend.log' -RedirectStandardError '.tmp-tools/backend-error.log'
}
$ready = $false
for ($attempt = 0; $attempt -lt 120; $attempt++) {
    $listening = @(Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LocalPort)
    if (@($ports | Where-Object { $_ -notin $listening }).Count -eq 0) { $ready = $true; break }
    Start-Sleep -Seconds 2
}
if (-not $ready) { throw 'Firebase did not become ready. Check .tmp-tools/backend.log and backend-error.log.' }
if ($Verify) {
    & node.exe --test backend/rules.test.cjs
    if ($LASTEXITCODE -ne 0) { throw 'Backend rule checks failed.' }
}
& node.exe -e "const {signIn,get}=require('./backend/emulator.cjs');signIn('student@my.sliit.lk').then(u=>get('users/'+u.localId,u.idToken)).catch(()=>process.exit(1));"
if ($LASTEXITCODE -ne 0) {
    & node.exe backend/seed.cjs
    if ($LASTEXITCODE -ne 0) { throw 'Could not seed demo data.' }
}
& firebase.cmd emulators:export emulator-data --project demo-sliit-peer --force
if ($LASTEXITCODE -ne 0) { throw 'Could not persist emulator data.' }
& flutter.bat run -d $Device
if ($LASTEXITCODE -ne 0) { throw 'Flutter could not launch the app.' }
