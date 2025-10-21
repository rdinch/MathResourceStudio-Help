# Script to create category folders in the activities directory
# Based on the desired folder structure

# Define the base activities path
$activitiesPath = Join-Path $PSScriptRoot "..\docs\activities"

# Define all category folders to create
$categoryFolders = @(
    "Advanced Number Operations",
    "Algebra",
    "Basic Number Operations",
    "Consumer Math",
    "Coordinates",
    "Custom",
    "Fractions",
    "Geometry",
    "Graph Paper",
    "Graphing",
    "Measurement",
    "Number Concepts",
    "Number Lines",
    "Numeration",
    "Probability",
    "Puzzles",
    "Ratio and Percent",
    "Tables and Drills",
    "Time"
)

Write-Host "Creating category folders in: $activitiesPath" -ForegroundColor Cyan
Write-Host ""

$createdCount = 0
$skippedCount = 0

foreach ($folder in $categoryFolders) {
    $folderPath = Join-Path $activitiesPath $folder
    
    if (Test-Path $folderPath) {
        Write-Host "  [SKIP] '$folder' already exists" -ForegroundColor Yellow
        $skippedCount++
    }
    else {
        New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
        Write-Host "  [CREATE] '$folder'" -ForegroundColor Green
        $createdCount++
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Created: $createdCount folders" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount folders (already existed)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Done! Category folders are ready." -ForegroundColor Green
