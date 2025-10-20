# PowerShell script to split the final clean manual into individual MkDocs files
# Based on bold underlined headings like **<u>Activity Name</u>**

$inputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_final_clean.md"
$outputDir = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\MRS8GitHub\MathResourceStudio-Help\docs"

Write-Host "Reading input file..." -ForegroundColor Green
$content = Get-Content $inputFile -Raw

# Find all bold underlined headings with their positions
$headingPattern = '\*\*<u>([^<]+)</u>\*\*'
$matches = [regex]::Matches($content, $headingPattern)

Write-Host "Found $($matches.Count) sections to split" -ForegroundColor Yellow

# Create output directories
$dirs = @("getting-started", "activities", "reference", "tutorials")
foreach ($dir in $dirs) {
    $fullPath = Join-Path $outputDir $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Cyan
    }
}

function Get-SafeFileName {
    param($title)
    # Convert title to safe filename
    $safe = $title -replace '[<>:"/\\|?*]', '' # Remove invalid chars
    $safe = $safe -replace '\s+', '-' # Replace spaces with hyphens
    $safe = $safe.ToLower() # Convert to lowercase
    return $safe + ".md"
}

function Get-CategoryFromTitle {
    param($title)
    
    # Categorize based on title content
    $title = $title.ToLower()
    
    # Getting started topics
    if ($title -match "what's new|creating|create a new|save|open|print|page setup|close") {
        return "getting-started"
    }
    
    # Reference topics (options, display settings, etc.)
    if ($title -match "display options|font|color|padding|border|background|answer lines|numbering|title|instructions") {
        return "reference"
    }
    
    # Math activities (specific exercise types)
    if ($title -match "addition|subtraction|multiplication|division|fraction|decimal|percent|algebra|geometry|time|money|measurement") {
        return "activities"
    }
    
    # Tutorial topics
    if ($title -match "working with|add a section|add an exercise|customize|design|header|footer|global") {
        return "tutorials"
    }
    
    # Default to reference for anything else
    return "reference"
}

# Process each section
for ($i = 0; $i -lt $matches.Count; $i++) {
    $currentMatch = $matches[$i]
    $title = $currentMatch.Groups[1].Value.Trim()
    $startPos = $currentMatch.Index
    
    # Find the end position (start of next section or end of file)
    if ($i -lt $matches.Count - 1) {
        $endPos = $matches[$i + 1].Index
    } else {
        $endPos = $content.Length
    }
    
    # Extract section content
    $sectionContent = $content.Substring($startPos, $endPos - $startPos).Trim()
    
    # Determine category and filename
    $category = Get-CategoryFromTitle $title
    $fileName = Get-SafeFileName $title
    $filePath = Join-Path (Join-Path $outputDir $category) $fileName
    
    # Create the file content with proper front matter
    $fileContent = @"
---
title: $title
category: $category
---

# $title

$sectionContent
"@
    
    # Write the file
    Set-Content -Path $filePath -Value $fileContent -Encoding UTF8
    Write-Host "Created: $category/$fileName" -ForegroundColor Green
}

Write-Host "`nDocument splitting completed!" -ForegroundColor Green
Write-Host "Files created in: $outputDir" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Review the categorization of files" -ForegroundColor White
Write-Host "2. Update mkdocs.yml with navigation structure" -ForegroundColor White
Write-Host "3. Test locally with 'mkdocs serve'" -ForegroundColor White