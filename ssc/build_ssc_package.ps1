# Build SSC Package for wbopendata v18.0.0
# Creates ssc_wbopendata.1800.zip with all files listed in ssc/wbopendata.pkg
#
# IMPORTANT: This script uses ssc/wbopendata.pkg (flat paths) NOT the root
# wbopendata.pkg (which has src/ paths for GitHub net install)
#
# Usage: .\build_ssc_package.ps1
# Output: ssc_wbopendata.1800.zip (in ssc/ directory)

Write-Host "=== Building SSC Package for wbopendata v18.0.0 ===" -ForegroundColor Green

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
    "wbopendata_whatsnew.sthlp",
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
    if (Test-Path "src\w\$file") {
        Copy-Item "src\w\$file" "$tempDir\" -Force
    } else {
        Write-Host "  WARNING: Missing src\w\$file" -ForegroundColor Red
    }
}

# Copy internal function files from src/_/ (ADO files)
Write-Host "Copying internal functions..." -ForegroundColor Cyan
$internalFiles = @(
    # Core API and query
    "_api_read.ado",
    "_api_read_indicators.ado",
    "_countrymetadata.ado",
    "_wbod_tmpfile1.ado",
    "_wbod_tmpfile2.ado",
    "_wbod_tmpfile3.ado",
    "_parameters.ado",
    "_query.ado",
    "_query_indicators.ado",
    "_query_metadata.ado",
    "_tknz.ado",
    "_website.ado",
    # Display helpers
    "_linewrap.ado",
    "_metadata_linewrap.ado",
    # Update system
    "_update_countrymetadata.ado",
    "_update_indicators.ado",
    "_update_regionmetadata.ado",
    "_update_wbopendata.ado",
    # Cache management (NEW v18.0)
    "_wbopendata_cache.ado",
    "_wbopendata_cache_clear.ado",
    "_wbopendata_cache_info.ado",
    "_wbopendata_check_version.ado",
    # YAML support (NEW v18.0)
    "_wbopendata_download_yaml.ado",
    "_wbopendata_get_yaml_path.ado",
    "_wbopendata_refresh_yaml.ado",
    # Discovery commands (NEW v18.0)
    "_wbopendata_get_source_name.ado",
    "_wbopendata_get_topic_name.ado",
    "_wbopendata_info.ado",
    "_wbopendata_search.ado",
    "_wbopendata_sources.ado",
    "_wbopendata_topics.ado",
    # Sync system (NEW v18.0)
    "_wbopendata_sync.ado",
    "_wbopendata_sync_preview.ado",
    "_wbopendata_write_stats_history.ado",
    # Internal sub-sub-routines (NEW v18.0)
    "__wbod_parse_yaml_ind.ado",
    "__wbopendata_search.ado",
    "__wbopendata_search_cache.ado"
)

foreach ($file in $internalFiles) {
    if (Test-Path "src\_\$file") {
        Copy-Item "src\_\$file" "$tempDir\" -Force
    } else {
        Write-Host "  WARNING: Missing src\_\$file" -ForegroundColor Red
    }
}

# Copy YAML metadata files from src/_/ (NEW v18.0)
Write-Host "Copying YAML metadata files..." -ForegroundColor Cyan
$yamlFiles = @(
    "_wbopendata_parameters.yaml",
    "_wbopendata_indicators.yaml",
    "_wbopendata_sources.yaml",
    "_wbopendata_topics.yaml"
)

foreach ($file in $yamlFiles) {
    if (Test-Path "src\_\$file") {
        Copy-Item "src\_\$file" "$tempDir\" -Force
    } else {
        Write-Host "  WARNING: Missing src\_\$file" -ForegroundColor Red
    }
}

# Copy YAML library from src/y/ (NEW v18.0)
Write-Host "Copying YAML library..." -ForegroundColor Cyan
$yamlLibFiles = @(
    "yaml.ado",
    "yaml.sthlp"
)

foreach ($file in $yamlLibFiles) {
    if (Test-Path "src\y\$file") {
        Copy-Item "src\y\$file" "$tempDir\" -Force
    } else {
        Write-Host "  WARNING: Missing src\y\$file" -ForegroundColor Red
    }
}

# Copy data files
Write-Host "Copying data files..." -ForegroundColor Cyan
Copy-Item "src\c\country.txt" "$tempDir\" -Force
Copy-Item "src\i\indicators.txt" "$tempDir\" -Force

# Count files and show summary
$fileCount = (Get-ChildItem "$tempDir" -File).Count
Write-Host "`n--- Package Summary ---" -ForegroundColor Yellow
Write-Host "Total files: $fileCount" -ForegroundColor Yellow

# Show file breakdown
$adoCount = (Get-ChildItem "$tempDir" -Filter "*.ado").Count
$sthlpCount = (Get-ChildItem "$tempDir" -Filter "*.sthlp").Count
$yamlCount = (Get-ChildItem "$tempDir" -Filter "*.yaml").Count
$dtaCount = (Get-ChildItem "$tempDir" -Filter "*.dta").Count
$otherCount = $fileCount - $adoCount - $sthlpCount - $yamlCount - $dtaCount
Write-Host "  ADO files:  $adoCount" -ForegroundColor Cyan
Write-Host "  STHLP files: $sthlpCount" -ForegroundColor Cyan
Write-Host "  YAML files: $yamlCount" -ForegroundColor Cyan
Write-Host "  DTA files:  $dtaCount" -ForegroundColor Cyan
Write-Host "  Other:      $otherCount" -ForegroundColor Cyan

# Create zip file
Write-Host "`nCreating zip file..." -ForegroundColor Cyan
$zipPath = "ssc\ssc_wbopendata.1800.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

# Verify zip
if (Test-Path $zipPath) {
    $sizeKB = (Get-Item $zipPath).Length / 1KB
    $sizeMB = (Get-Item $zipPath).Length / 1MB
    Write-Host "`n=== Package created successfully! ===" -ForegroundColor Green
    Write-Host "  Location: $zipPath" -ForegroundColor Cyan
    Write-Host "  Size: $([Math]::Round($sizeMB, 2)) MB ($([Math]::Round($sizeKB, 2)) KB)" -ForegroundColor Cyan
    Write-Host "  Files: $fileCount" -ForegroundColor Cyan
}
else {
    Write-Host "`n=== Failed to create package ===" -ForegroundColor Red
    exit 1
}

# Clean up temp directory
Remove-Item $tempDir -Recurse -Force
Write-Host "`nCleaned up temporary files" -ForegroundColor Green

Write-Host "`n=== Package ready for SSC submission ===" -ForegroundColor Green
Write-Host "NOTE: Python files (src/py/) are excluded from SSC." -ForegroundColor Yellow
Write-Host "      They are developer tools for metadata updates." -ForegroundColor Yellow
