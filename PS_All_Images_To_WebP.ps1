#Requires -Version 5.0

################################################## GLOBAL VARIABLES / SETTINGS

### Folders settings
$InputFolder = "$PWD"
$OutputFolder = "$InputFolder\webp"

### Extensions settings
$JpgExtensions = @("*.jpg", "*.jpeg", "*.jpe")
$PngExtensions = @("*.png")
$ImageExtensions = $JpgExtensions + $PngExtensions

### Quality settings
$Quality = 75 # in percent (0-100)
# 85 - best quality
# 75 - default (balance)
# 55 - saves space, not bad for high resolution (1.5к+)
$EndQualityPreset = @("-q", $Quality)

################################################## FUNCTIONS

function ConvertTo-WebP([string]$InputImagePath,[string]$OutputImagePath,[object[]]$QualityPreset) {
  cwebp $QualityPreset $InputImagePath -o $OutputImagePath
}

function Convert-AllJpgToWebP([string]$InputFolder = $InputFolder, [string]$OutputFolder = $OutputFolder) {

  $Images = Get-ChildItem -Path "$InputFolder\*" -Include $ImageExtensions

  foreach ($Img in $Images) {

    $OutputName = "$OutputFolder\$($Img.BaseName).webp"
    ConvertTo-WebP $Img.FullName $OutputName $EndQualityPreset

    Write-Host ("=" * 100)

  }

}

################################################## MAIN

if (!(Test-Path -Path "$OutputFolder")) {
  New-Item -ItemType "directory" -Path "$OutputFolder" | Out-Null
}

Convert-AllJpgToWebP
Pause