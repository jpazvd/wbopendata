# Build SSC Package for wbopendata v18.4.1
# Creates wbopendata-v18.4.1.zip with all files listed in wbopendata.pkg
#
# IMPORTANT: SSC requires flat paths (no subdirectories). All files are
# copied to a temp directory and zipped flat.
# Python files (src/py/) and __COMPONENT_VERSIONS.yaml are excluded from SSC.
#
# Usage: .\build_ssc_package.ps1
# Output: ssc\wbopendata-v18.4.1.zip

$version = "18.4.1"
Write-Host "=== Building SSC Package for wbopendata v$version ===" -ForegroundColor Green

# Navigate to repository root
Set-Location (Split-Path $PSScriptRoot -Parent)

# Create temporary directory for package files
$tempDir = "ssc_package_temp"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copy package metadata files directly from src/ (flat paths for SSC)
Write-Host "`nCopying package metadata..." -ForegroundColor Cyan
Copy-Item "src\stata.toc" "$tempDir\" -Force
Copy-Item "src\wbopendata.pkg" "$tempDir\" -Force

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

# Copy internal function files from src/_/
Write-Host "Copying internal functions..." -ForegroundColor Cyan
$internalFiles = @(
    # Core API and query
    "__wbod_api_read.ado",
    "__wbod_api_read_indicators.ado",
    "__wbod_countrymetadata.ado",
    "_wbod_tmpfile1.ado",
    "_wbod_tmpfile2.ado",
    "_wbod_tmpfile3.ado",
    "__wbod_parameters.ado",
    "__wbod_query.ado",
    "__wbod_query_indicators.ado",
    "__wbod_query_metadata.ado",
    "__wbod_tknz.ado",
    "__wbod_website.ado",
    # Display helpers
    "__wbod_linewrap.ado",
    "__wbod_metadata_linewrap.ado",
    # Update system
    "__wbod_update_countrymetadata.ado",
    "__wbod_update_indicators.ado",
    "__wbod_update_regionmetadata.ado",
    "__wbod_update_wbopendata.ado",
    # Cache and version management
    "__wbod_cache.ado",
    "__wbod_check_version.ado",
    "__wbod_check_yaml.ado",
    # YAML support
    "__wbod_get_yaml_path.ado",
    "__wbod_refresh_yaml.ado",
    "__wbod_yaml_metadata.ado",
    "__yaml_collapse.ado",
    "__yaml_fastread.ado",
    "__yaml_mataread.ado",
    "__yaml_tokenize_line.ado",
    # Discovery commands
    "__wbod_get_source_name.ado",
    "__wbod_get_topic_name.ado",
    "__wbod_info.ado",
    "__wbod_search.ado",
    "__wbopendata_search.ado",
    "__wbopendata_search_cache.ado",
    "__wbod_sources.ado",
    "__wbod_topics.ado",
    # Sync system
    "__wbod_sync.ado",
    "__wbod_sync_preview.ado",
    "__wbod_write_stats_history.ado",
    # YAML parser
    "__wbod_parse_yaml_ind.ado",
    "__wbod_parse_yaml_ind_v2.ado"
)

foreach ($file in $internalFiles) {
    if (Test-Path "src\_\$file") {
        Copy-Item "src\_\$file" "$tempDir\" -Force
    } else {
        Write-Host "  WARNING: Missing src\_\$file" -ForegroundColor Red
    }
}

# Copy YAML metadata files from src/_/
# Note: __COMPONENT_VERSIONS.yaml is an internal manifest — excluded from SSC
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

# Copy YAML library from src/y/
Write-Host "Copying YAML library..." -ForegroundColor Cyan
$yamlLibFiles = @(
    "yaml.ado",
    "yaml.sthlp",
    "yaml_read.ado",
    "yaml_get.ado",
    "yaml_write.ado",
    "yaml_list.ado",
    "yaml_describe.ado",
    "yaml_dir.ado",
    "yaml_clear.ado",
    "yaml_validate.ado",
    "yaml_frames.ado",
    "yaml_examples.sthlp",
    "yaml_whatsnew.sthlp"
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

$adoCount   = (Get-ChildItem "$tempDir" -Filter "*.ado").Count
$sthlpCount = (Get-ChildItem "$tempDir" -Filter "*.sthlp").Count
$yamlCount  = (Get-ChildItem "$tempDir" -Filter "*.yaml").Count
$dtaCount   = (Get-ChildItem "$tempDir" -Filter "*.dta").Count
$otherCount = $fileCount - $adoCount - $sthlpCount - $yamlCount - $dtaCount
Write-Host "  ADO files:   $adoCount"   -ForegroundColor Cyan
Write-Host "  STHLP files: $sthlpCount" -ForegroundColor Cyan
Write-Host "  YAML files:  $yamlCount"  -ForegroundColor Cyan
Write-Host "  DTA files:   $dtaCount"   -ForegroundColor Cyan
Write-Host "  Other:       $otherCount" -ForegroundColor Cyan

# Create zip file
Write-Host "`nCreating zip file..." -ForegroundColor Cyan
$zipPath = "ssc\wbopendata-v$version.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

# Verify zip
if (Test-Path $zipPath) {
    $sizeMB = (Get-Item $zipPath).Length / 1MB
    $sizeKB = (Get-Item $zipPath).Length / 1KB
    Write-Host "`n=== Package created successfully! ===" -ForegroundColor Green
    Write-Host "  Location: $zipPath" -ForegroundColor Cyan
    Write-Host "  Size: $([Math]::Round($sizeMB, 2)) MB ($([Math]::Round($sizeKB, 2)) KB)" -ForegroundColor Cyan
    Write-Host "  Files: $fileCount" -ForegroundColor Cyan
} else {
    Write-Host "`n=== Failed to create package ===" -ForegroundColor Red
    exit 1
}

# Clean up temp directory
Remove-Item $tempDir -Recurse -Force
Write-Host "`nCleaned up temporary files" -ForegroundColor Green

Write-Host "`n=== Package ready for SSC submission ===" -ForegroundColor Green
Write-Host "NOTE: Python files (src/py/) excluded — developer tools only." -ForegroundColor Yellow
Write-Host "NOTE: __COMPONENT_VERSIONS.yaml excluded — internal manifest only." -ForegroundColor Yellow
