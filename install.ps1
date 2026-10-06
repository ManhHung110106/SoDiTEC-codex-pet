param([string]$CodexHome = $env:CODEX_HOME)
$ErrorActionPreference = 'Stop'
try {
    $source = Join-Path $PSScriptRoot 'SodiWorm'
    if (-not (Test-Path -LiteralPath (Join-Path $source 'pet.json') -PathType Leaf)) {
        $source = Join-Path $PSScriptRoot 'pets\SodiWorm'
    }
    $files = @('pet.json', 'spritesheet.png', 'animation-mappings.json', 'preview.html', 'README.md', 'LICENSE')
    foreach ($name in $files) {
        if (-not (Test-Path -LiteralPath (Join-Path $source $name) -PathType Leaf)) {
            throw "Missing $name. Extract the complete ZIP before running install.bat."
        }
    }
    $config = Get-Content -LiteralPath (Join-Path $source 'pet.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($config.displayName -ne 'SodiWorm' -or $config.spriteVersionNumber -ne 2 -or $config.spritesheetPath -ne 'spritesheet.png') {
        throw 'Invalid SodiWorm pet configuration.'
    }
    if ([string]::IsNullOrWhiteSpace($CodexHome)) {
        if ([string]::IsNullOrWhiteSpace($env:USERPROFILE)) { throw 'Windows user profile was not found.' }
        $CodexHome = Join-Path $env:USERPROFILE '.codex'
    }
    $resolvedHome = [IO.Path]::GetFullPath($CodexHome)
    $destination = Join-Path $resolvedHome 'pets\SodiWorm'
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    foreach ($name in $files) {
        $inputFile = Join-Path $source $name
        $outputFile = Join-Path $destination $name
        if ([IO.Path]::GetFullPath($inputFile) -ne [IO.Path]::GetFullPath($outputFile)) {
            Copy-Item -LiteralPath $inputFile -Destination $outputFile -Force
        }
    }
    Write-Host ''
    Write-Host 'SodiWorm installed successfully!' -ForegroundColor Green
    Write-Host "Location: $destination"
    Write-Host 'Open Codex > Settings > Pets, refresh the list and select SodiWorm.'
    Write-Host 'If it is not listed yet, restart Codex.'
    Write-Host 'Artwork use requires prior permission from SoDiTEC; see LICENSE.'
    exit 0
} catch {
    Write-Host "Installation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
