$projectPath = $PWD.Path
$buildDir = Join-Path $projectPath "build"

if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

$godotPath = & "$projectPath\find_godot.ps1"

if ($godotPath -eq "NOT_FOUND") {
    Write-Host "Error: Godot Engine not found."
    exit 1
}

Write-Host "Found Godot: $godotPath"
Write-Host "Exporting project..."

& $godotPath --path $projectPath --export-release "Windows Desktop" "$buildDir\TwilightOfTheGods.exe"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build successful!"
    Write-Host "Executable: $buildDir\TwilightOfTheGods.exe"
} else {
    Write-Host "Build failed with exit code: $LASTEXITCODE"
    exit $LASTEXITCODE
}