# Build SSC Package for wbopendata v18.4.1
# Creates wbopendata-v18.4.1.zip for submission to Kit Baum (baum@bc.edu)
#
# Directory structure is preserved in the zip (w/, _/, y/, py/, c/, i/).
# Stata's net/ssc commands install each file into the matching subdirectory
# under ado/plus/ (e.g. py/ -> ado/plus/py/, _/ -> ado/plus/_/).
#
# Excluded from zip:
#   - py/update_metadata.do  : hardcoded developer paths
#   - __COMPONENT_VERSIONS.yaml : internal manifest
#
# Usage: .\build_ssc_package.ps1  (run from ssc\ or repo root)
# Output: ssc\wbopendata-v18.4.1.zip

$version = "18.4.1"
Write-Host "=== Building SSC Package for wbopendata v$version ===" -ForegroundColor Green

# Navigate to repository root
Set-Location (Split-Path $PSScriptRoot -Parent)

# Create temporary directory (preserving subdirectory structure)
$tempDir = "ssc_package_temp"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
foreach ($sub in @("", "w", "_", "y", "py", "c", "i")) {
    New-Item -ItemType Directory -Path (Join-Path $tempDir $sub) -Force | Out-Null
}

# --- Package metadata (zip root) ---
Write-Host "`nCopying package metadata..." -ForegroundColor Cyan
Copy-Item "src\stata.toc"      "$tempDir\" -Force
Copy-Item "src\wbopendata.pkg" "$tempDir\" -Force

# --- w/ : main wbopendata files ---
Write-Host "Copying w/ files..." -ForegroundColor Cyan
$wFiles = @(
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
foreach ($f in $wFiles) {
    if (Test-Path "src\w\$f") { Copy-Item "src\w\$f" "$tempDir\w\" -Force }
    else { Write-Host "  WARNING: missing src\w\$f" -ForegroundColor Red }
}

# --- _/ : internal ADO helpers + YAML metadata ---
Write-Host "Copying _/ files..." -ForegroundColor Cyan
$uFiles = @(
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
    "__wbod_parse_yaml_ind_v2.ado",
    # YAML metadata files (note: __COMPONENT_VERSIONS.yaml excluded)
    "_wbopendata_parameters.yaml",
    "_wbopendata_indicators.yaml",
    "_wbopendata_sources.yaml",
    "_wbopendata_topics.yaml"
)
foreach ($f in $uFiles) {
    if (Test-Path "src\_\$f") { Copy-Item "src\_\$f" "$tempDir\_\" -Force }
    else { Write-Host "  WARNING: missing src\_\$f" -ForegroundColor Red }
}

# --- y/ : YAML library ---
Write-Host "Copying y/ files..." -ForegroundColor Cyan
$yFiles = @(
    "yaml.ado", "yaml.sthlp",
    "yaml_read.ado", "yaml_get.ado", "yaml_write.ado",
    "yaml_list.ado", "yaml_describe.ado", "yaml_dir.ado",
    "yaml_clear.ado", "yaml_validate.ado", "yaml_frames.ado",
    "yaml_examples.sthlp", "yaml_whatsnew.sthlp"
)
foreach ($f in $yFiles) {
    if (Test-Path "src\y\$f") { Copy-Item "src\y\$f" "$tempDir\y\" -Force }
    else { Write-Host "  WARNING: missing src\y\$f" -ForegroundColor Red }
}

# --- py/ : Python pipeline for forcepython pathway ---
# Note: update_metadata.do excluded (hardcoded dev paths)
Write-Host "Copying py/ files..." -ForegroundColor Cyan
$pyFiles = @(
    "__init__.py",
    "update_metadata.py",
    "wb_api_client.py",
    "yaml_generator.py",
    "schema_validator.py",
    "diff_analyzer.py",
    "git_manager.py"
)
foreach ($f in $pyFiles) {
    if (Test-Path "src\py\$f") { Copy-Item "src\py\$f" "$tempDir\py\" -Force }
    else { Write-Host "  WARNING: missing src\py\$f" -ForegroundColor Red }
}

# --- c/ and i/ : data files ---
Write-Host "Copying data files..." -ForegroundColor Cyan
Copy-Item "src\c\country.txt"    "$tempDir\c\" -Force
Copy-Item "src\i\indicators.txt" "$tempDir\i\" -Force

# --- Summary ---
$allFiles  = Get-ChildItem "$tempDir" -Recurse -File
$fileCount = $allFiles.Count
$adoCount   = ($allFiles | Where-Object { $_.Extension -eq ".ado"   }).Count
$sthlpCount = ($allFiles | Where-Object { $_.Extension -eq ".sthlp" }).Count
$yamlCount  = ($allFiles | Where-Object { $_.Extension -eq ".yaml"  }).Count
$dtaCount   = ($allFiles | Where-Object { $_.Extension -eq ".dta"   }).Count
$pyCount    = ($allFiles | Where-Object { $_.Extension -eq ".py"    }).Count
$otherCount = $fileCount - $adoCount - $sthlpCount - $yamlCount - $dtaCount - $pyCount

Write-Host "`n--- Package Summary ---" -ForegroundColor Yellow
Write-Host "Total files: $fileCount" -ForegroundColor Yellow
Write-Host "  ADO files:   $adoCount"   -ForegroundColor Cyan
Write-Host "  STHLP files: $sthlpCount" -ForegroundColor Cyan
Write-Host "  YAML files:  $yamlCount"  -ForegroundColor Cyan
Write-Host "  DTA files:   $dtaCount"   -ForegroundColor Cyan
Write-Host "  PY files:    $pyCount"    -ForegroundColor Cyan
Write-Host "  Other:       $otherCount" -ForegroundColor Cyan

# --- Zip ---
Write-Host "`nCreating zip file..." -ForegroundColor Cyan
$zipPath = "ssc\wbopendata-v$version.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -CompressionLevel Optimal

if (Test-Path $zipPath) {
    $sizeKB = [Math]::Round((Get-Item $zipPath).Length / 1KB, 0)
    $sizeMB = [Math]::Round((Get-Item $zipPath).Length / 1MB, 2)
    Write-Host "`n=== Package created successfully! ===" -ForegroundColor Green
    Write-Host "  Location: $zipPath" -ForegroundColor Cyan
    Write-Host "  Size:     $sizeMB MB ($sizeKB KB)" -ForegroundColor Cyan
    Write-Host "  Files:    $fileCount" -ForegroundColor Cyan
} else {
    Write-Host "`n=== Failed to create package ===" -ForegroundColor Red
    exit 1
}

# --- Cleanup ---
Remove-Item $tempDir -Recurse -Force
Write-Host "`nCleaned up temporary files" -ForegroundColor Green
Write-Host "`n=== Package ready for SSC submission ===" -ForegroundColor Green
Write-Host "NOTE: py/update_metadata.do excluded — hardcoded dev paths." -ForegroundColor Yellow
Write-Host "NOTE: __COMPONENT_VERSIONS.yaml excluded — internal manifest." -ForegroundColor Yellow
