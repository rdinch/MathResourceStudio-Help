# Script to generate nested navigation structure for the Activities section
# This will create YAML navigation that matches the new folder structure

# Define the base activities path
$activitiesPath = Join-Path $PSScriptRoot "..\docs\activities"
$outputFile = Join-Path $PSScriptRoot "activities-nav.yml"

Write-Host "Generating nested navigation structure..." -ForegroundColor Cyan
Write-Host ""

# Define the category order (matching the original structure)
$categoryOrder = @(
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

# Helper function to convert filename to title
function Get-TitleFromFilename {
    param([string]$filename)
    
    # Remove .md extension
    $title = $filename -replace '\.md$', ''
    
    # Replace hyphens with spaces
    $title = $title -replace '-', ' '
    
    # Replace --- with proper separator
    $title = $title -replace '\s{3}', ': '
    
    # Capitalize first letter of each word
    $title = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
    
    return $title
}

# Start building the YAML content
$yamlContent = @()
$yamlContent += "  - Activities:"

$totalFiles = 0
$totalCategories = 0

foreach ($category in $categoryOrder) {
    $categoryPath = Join-Path $activitiesPath $category
    
    if (Test-Path $categoryPath) {
        # Get all .md files in this category
        $files = Get-ChildItem -Path $categoryPath -Filter "*.md" | Sort-Object Name
        
        if ($files.Count -gt 0) {
            Write-Host "Processing: $category ($($files.Count) files)" -ForegroundColor Yellow
            
            # Add category header
            $yamlContent += "    - ${category}:"
            
            # Add each file under this category
            foreach ($file in $files) {
                $title = Get-TitleFromFilename $file.Name
                $relativePath = "activities/$category/$($file.Name)"
                $yamlContent += "      - `"$title`": $relativePath"
                $totalFiles++
            }
            
            $totalCategories++
        }
    }
    else {
        Write-Host "Warning: Category folder not found: $category" -ForegroundColor Red
    }
}

# Write the YAML content to file
$yamlContent | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Categories processed: $totalCategories" -ForegroundColor White
Write-Host "  Total files included: $totalFiles" -ForegroundColor Green
Write-Host ""
Write-Host "Output saved to: $outputFile" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Open mkdocs.yml" -ForegroundColor White
Write-Host "2. Find the 'Activities:' section in the nav" -ForegroundColor White
Write-Host "3. Replace the entire Activities section with the content from:" -ForegroundColor White
Write-Host "   $outputFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Done!" -ForegroundColor Green
