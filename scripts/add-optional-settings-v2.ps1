# Script to add Optional Settings section to all activity markdown files

$activitiesPath = Join-Path $PSScriptRoot "..\docs\activities"
$optionalSettingsSection = @"

Optional Settings

- [Exercise Set Display](../../options/exercise-set-display-options.md)
- [Title](../../options/title-display-options.md)
- [Instructions](../../options/instructions-display-options.md)
- [Numbering](../../options/numbering-display-options.md)
- [Answer Bank](../../options/answer-bank-display-options.md)
"@

# Get all markdown files in the activities subdirectories
$activityFiles = Get-ChildItem -Path $activitiesPath -Recurse -Filter "*.md"

Write-Host "Found $($activityFiles.Count) activity files" -ForegroundColor Cyan
Write-Host ""

$modified = 0
$skipped = 0
$alreadyHas = 0

foreach ($file in $activityFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Skip empty files
    if ([string]::IsNullOrWhiteSpace($content)) {
        $skipped++
        continue
    }
    
    # Check if the file already has "Optional Settings" section
    if ($content -match "Optional Settings") {
        $alreadyHas++
        continue
    }
    
    # Remove trailing whitespace and add the section
    $content = $content.TrimEnd()
    $newContent = $content + $optionalSettingsSection
    
    # Write back to file
    Set-Content -Path $file.FullName -Value $newContent -NoNewline
    
    $relativePath = $file.FullName.Replace($activitiesPath + "\", "")
    Write-Host "  ✓ Modified: $relativePath" -ForegroundColor Green
    $modified++
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Modified: $modified files" -ForegroundColor Green
Write-Host "Already had section: $alreadyHas files" -ForegroundColor Yellow
Write-Host "Skipped (empty): $skipped files" -ForegroundColor Gray
Write-Host ""
