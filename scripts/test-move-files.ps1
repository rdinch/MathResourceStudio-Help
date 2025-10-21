# Test script to move files into the "Advanced Number Operations" folder
# This is a test run for the first category only

# Define the base activities path
$activitiesPath = Join-Path $PSScriptRoot "..\docs\activities"
$categoryFolder = "Advanced Number Operations"
$categoryPath = Join-Path $activitiesPath $categoryFolder

Write-Host "Test: Moving files to '$categoryFolder'" -ForegroundColor Cyan
Write-Host "Target path: $categoryPath" -ForegroundColor Gray
Write-Host ""

# Files that belong in "Advanced Number Operations" based on the structure
$filesToMove = @(
    "advanced-addition.md",
    "advanced-division.md",
    "advanced-division---no-remainders.md",
    "advanced-division---remainders.md",
    "advanced-division-selected-divisors.md",
    "advanced-multiplication.md",
    "advanced-multiplication---selected-multipliers.md",
    "advanced-subtraction.md",
    "mixed-advanced-operations.md",
    "multiple-addends.md",
    "multiple-operations.md",
    "multiple-operations-missing-operations.md",
    "powers-of-ten.md"
)

$movedCount = 0
$notFoundCount = 0

foreach ($fileName in $filesToMove) {
    $sourcePath = Join-Path $activitiesPath $fileName
    $destPath = Join-Path $categoryPath $fileName
    
    if (Test-Path $sourcePath) {
        Move-Item -Path $sourcePath -Destination $destPath -Force
        Write-Host "  [MOVED] $fileName" -ForegroundColor Green
        $movedCount++
    }
    else {
        Write-Host "  [NOT FOUND] $fileName" -ForegroundColor Red
        $notFoundCount++
    }
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Moved: $movedCount files" -ForegroundColor Green
Write-Host "  Not found: $notFoundCount files" -ForegroundColor Red
Write-Host ""

if ($notFoundCount -eq 0) {
    Write-Host "Success! All files for '$categoryFolder' have been moved." -ForegroundColor Green
}
else {
    Write-Host "Warning: Some files were not found. Review the list above." -ForegroundColor Yellow
}
