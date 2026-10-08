param([string]$Device = 'emulator-5554', [string]$Config = 'android/app/google-services.json')
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (-not (Test-Path -LiteralPath $Config)) {
    throw 'Download google-services.json for com.example.sliit_peer_tutoring from Firebase Console and place it in android/app.'
}
$firebaseConfig = Get-Content -LiteralPath $Config -Raw | ConvertFrom-Json
$client = @($firebaseConfig.client | Where-Object { $_.client_info.android_client_info.package_name -eq 'com.example.sliit_peer_tutoring' })
if ($client.Count -ne 1) { throw 'The Firebase configuration must contain the Android package com.example.sliit_peer_tutoring.' }
$project = $firebaseConfig.project_info
$apiKey = @($client[0].api_key)[0].current_key
if (-not $project.project_id -or $project.project_id -like 'demo-*' -or -not $apiKey -or -not $project.project_number -or -not $client[0].client_info.mobilesdk_app_id) {
    throw 'The Firebase Android configuration is incomplete. Download it again from Firebase Console.'
}
& flutter.bat --no-version-check run -d $Device `
    '--dart-define=USE_FIREBASE_EMULATORS=false' `
    '--dart-define=ENABLE_FILE_UPLOADS=false' `
    "--dart-define=FIREBASE_PROJECT_ID=$($project.project_id)" `
    "--dart-define=FIREBASE_API_KEY=$apiKey" `
    "--dart-define=FIREBASE_APP_ID=$($client[0].client_info.mobilesdk_app_id)" `
    "--dart-define=FIREBASE_SENDER_ID=$($project.project_number)" `
    "--dart-define=FIREBASE_STORAGE_BUCKET=$($project.storage_bucket)"
if ($LASTEXITCODE -ne 0) { throw 'Cloud app launch failed.' }
