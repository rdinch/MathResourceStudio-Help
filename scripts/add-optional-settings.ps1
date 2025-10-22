# Script to add Optional Settings section to all activity markdown files
# This script will add a standard set of links to option files at the bottom of each activity file

param(
    [switch]$Preview,  # If set, only shows what would be changed without making changes
    [switch]$Force     # If set, will overwrite existing Optional Settings sections
)

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

$filesToModify = @()
$filesWithExisting = @()
$filesWithoutContent = @()

foreach ($file in $activityFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Skip empty files
    if ([string]::IsNullOrWhiteSpace($content)) {
        $filesWithoutContent += $file
        continue
    }
    
    # Check if the file already has "Optional Settings" section
    if ($content -match "Optional Settings") {
        $filesWithExisting += $file
        continue
    }
    
    $filesToModify += $file
}

# Display preview
Write-Host "=== PREVIEW ===" -ForegroundColor Yellow
Write-Host ""

if ($filesToModify.Count -gt 0) {
    Write-Host "Files that will have Optional Settings added ($($filesToModify.Count)):" -ForegroundColor Green
    foreach ($file in $filesToModify) {
        $relativePath = $file.FullName.Replace($activitiesPath + "\", "")
        Write-Host "  ✓ $relativePath" -ForegroundColor Green
    }
    Write-Host ""
}

if ($filesWithExisting.Count -gt 0) {
    Write-Host "Files that already have Optional Settings ($($filesWithExisting.Count)):" -ForegroundColor Yellow
    foreach ($file in $filesWithExisting) {
        $relativePath = $file.FullName.Replace($activitiesPath + "\", "")
        Write-Host "  ⊙ $relativePath" -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($filesWithoutContent.Count -gt 0) {
    Write-Host "Files that are empty and will be skipped ($($filesWithoutContent.Count)):" -ForegroundColor Gray
    foreach ($file in $filesWithoutContent) {
        $relativePath = $file.FullName.Replace($activitiesPath + "\", "")
        Write-Host "  - $relativePath" -ForegroundColor Gray
    }
    Write-Host ""
}

# If preview mode, exit here
if ($Preview) {
    Write-Host "Preview mode - no changes made." -ForegroundColor Cyan
    Write-Host "Run without -Preview parameter to apply changes." -ForegroundColor Cyan
    exit
}

# Ask for confirmation if not in preview mode
if ($filesToModify.Count -eq 0) {
    Write-Host "No files need to be modified." -ForegroundColor Cyan
    exit
}

$response = Read-Host "Do you want to proceed with modifying $($filesToModify.Count) files? [y/n]"
if ($response -ne 'y' -and $response -ne 'Y') {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit
}

# Apply changes
Write-Host ""
Write-Host "=== APPLYING CHANGES ===" -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$errorCount = 0

foreach ($file in $filesToModify) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Remove trailing whitespace and ensure single newline at end before adding section
        $content = $content.TrimEnd()
        
        # Add the optional settings section
        $newContent = $content + $optionalSettingsSection
        
        # Write back to file
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        
        $relativePath = $file.FullName.Replace($activitiesPath + "\", "")
        Write-Host "  ✓ Modified: $relativePath" -ForegroundColor Green
        $successCount++
    }
    catch {
        $relativePath = $file.FullName.Replace($activitiesPath + "\", "")
        Write-Host "  ✗ Error: $relativePath - $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Successfully modified: $successCount files" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Errors: $errorCount files" -ForegroundColor Red
}
Write-Host ""
