# Script to move "add-" files from reference to design-elements folder
# and update mkdocs.yml navigation

$sourceFolder = Join-Path $PSScriptRoot "..\docs\reference"
$targetFolder = Join-Path $PSScriptRoot "..\docs\design-elements"
$mkdocsFile = Join-Path $PSScriptRoot "..\mkdocs.yml"

# Files to move (all files starting with "add-")
$filesToMove = @(
    "add-a-background-picture.md",
    "add-a-fraction-line.md",
    "add-a-line.md",
    "add-a-number-line.md",
    "add-a-picture.md",
    "add-a-title-group.md",
    "add-a-title.md",
    "add-an-epigraph.md",
    "add-text.md",
    "add-vertical-spacing.md"
)

Write-Host "=== Moving Files ===" -ForegroundColor Cyan
Write-Host ""

# Create target folder if it doesn't exist
if (-not (Test-Path $targetFolder)) {
    New-Item -Path $targetFolder -ItemType Directory | Out-Null
    Write-Host "Created folder: design-elements" -ForegroundColor Green
}

# Move files
$movedFiles = @()
foreach ($file in $filesToMove) {
    $sourcePath = Join-Path $sourceFolder $file
    $targetPath = Join-Path $targetFolder $file
    
    if (Test-Path $sourcePath) {
        Move-Item -Path $sourcePath -Destination $targetPath -Force
        Write-Host "  ✓ Moved: $file" -ForegroundColor Green
        $movedFiles += $file
    } else {
        Write-Host "  ✗ Not found: $file" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Updating Navigation ===" -ForegroundColor Cyan
Write-Host ""

# Read mkdocs.yml
$content = Get-Content $mkdocsFile -Raw

# Update paths from reference/ to design-elements/
$newContent = $content
foreach ($file in $movedFiles) {
    $oldPath = "reference/$file"
    $newPath = "design-elements/$file"
    $newContent = $newContent -replace [regex]::Escape($oldPath), $newPath
}

# Check if a Design Elements section already exists in nav
if ($newContent -notmatch '  - Design Elements:') {
    Write-Host "Adding 'Design Elements' section to navigation..." -ForegroundColor Yellow
    
    # Find the Reference section and add Design Elements before it
    $refPattern = '(?m)^  - Reference:'
    if ($newContent -match $refPattern) {
        $designElementsSection = "  - Design Elements:`n"
        foreach ($file in $movedFiles) {
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file)
            # Convert filename to title (e.g., add-a-picture -> Add A Picture)
            $title = ($fileName -replace '-', ' ').Split(' ') | ForEach-Object { 
                $_.Substring(0,1).ToUpper() + $_.Substring(1) 
            }
            $title = $title -join ' '
            $designElementsSection += "    - `"$title`": design-elements/$file`n"
        }
        $newContent = $newContent -replace $refPattern, "$designElementsSection  - Reference:"
    }
}

# Write back to mkdocs.yml
Set-Content $mkdocsFile -Value $newContent -NoNewline

Write-Host "  ✓ Updated mkdocs.yml" -ForegroundColor Green
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Moved files: $($movedFiles.Count)" -ForegroundColor Green
Write-Host "Navigation updated successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Note: The moved files have been removed from the Reference section in navigation." -ForegroundColor Yellow
Write-Host "You may want to verify the mkdocs.yml file." -ForegroundColor Yellow
