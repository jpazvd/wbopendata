# Build SSC Package for wbopendata
# Creates ssc_wbopendata.zip with all files listed in ssc/wbopendata.pkg
# 
# IMPORTANT: This script uses ssc/wbopendata.pkg (flat paths) NOT the root
# wbopendata.pkg (which has src/ paths for GitHub net install)
#
# Usage: .\build_ssc_package.ps1
# Output: ssc_wbopendata.zip (in current directory)

Write-Host "=== Building SSC Package for wbopendata ===" -ForegroundColor Green

# Navigate to repository root
Set-Location (Split-Path $PSScriptRoot -Parent)

# Create temporary directory for package files
$tempDir = "ssc_package_temp"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copy package metadata files (use SSC versions with flat paths)
Write-Host "`nCopying package metadata..." -ForegroundColor Cyan
Copy-Item "ssc\stata.toc" "$tempDir\" -Force
Copy-Item "ssc\wbopendata.pkg" "$tempDir\" -Force

# Copy main wbopendata files from src/w/
Write-Host "Copying main wbopendata files..." -ForegroundColor Cyan
$mainFiles = @(
    "wbopendata.ado",
    "wbopendata_populate_list.ado",
    "wbopendata_examples.ado",
    "wbopendata.sthlp",
    "wbopendata.dlg",
    "wbopendata_indicators.sthlp",
    "wbopendata_adminregion.sthlp",
    "wbopendata_incomelevel.sthlp",
    "wbopendata_lendingtype.sthlp",
    "wbopendata_region.sthlp",
    "wbopendata_sourceid.sthlp",
    "wbopendata_topicid.sthlp",
    "world-c.dta",
    "world-d.dta"
)

foreach ($file in $mainFiles) {
    Copy-Item "src\w\$file" "$tempDir\" -Force
}

# Copy internal function files from src/_/
Write-Host "Copying internal functions..." -ForegroundColor Cyan
$internalFiles = @(
    "_api_read.ado",
    "_api_read_indicators.ado",
    "_countrymetadata.ado",
    "_linewrap.ado",
    "_metadata_linewrap.ado",
    "_parameters.ado",
    "_query.ado",
    "_query_indicators.ado",
    "_query_metadata.ado",
    "_tknz.ado",
    "_update_countrymetadata.ado",
    "_update_indicators.ado",
    "_update_regionmetadata.ado",
    "_update_wbopendata.ado",
    "_wbod_tmpfile1.ado",
    "_wbod_tmpfile2.ado",
    "_wbod_tmpfile3.ado",
    "_website.ado"
)

foreach ($file in $internalFiles) {
    Copy-Item "src\_\$file" "$tempDir\" -Force
}

# Copy data files
Write-Host "Copying data files..." -ForegroundColor Cyan
Copy-Item "src\c\country.txt" "$tempDir\" -Force
Copy-Item "src\i\indicators.txt" "$tempDir\" -Force

# Count files
$fileCount = (Get-ChildItem "$tempDir" -File).Count
Write-Host "`nTotal files: $fileCount" -ForegroundColor Yellow

# Create zip file
Write-Host "`nCreating zip file..." -ForegroundColor Cyan
$zipPath = "ssc\ssc_wbopendata.171.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

# Verify zip
if (Test-Path $zipPath) {
    $size = (Get-Item $zipPath).Length / 1KB
    Write-Host "`n✓ Package created successfully!" -ForegroundColor Green
    Write-Host "  Location: $zipPath" -ForegroundColor Cyan
    Write-Host "  Size: $([Math]::Round($size, 2)) KB" -ForegroundColor Cyan
    Write-Host "  Files: $fileCount" -ForegroundColor Cyan
} else {
    Write-Host "`n✗ Failed to create package" -ForegroundColor Red
    exit 1
}

# Clean up temp directory
Remove-Item $tempDir -Recurse -Force
Write-Host "`n✓ Cleaned up temporary files" -ForegroundColor Green

Write-Host "`n=== Package ready for SSC submission ===" -ForegroundColor Green
