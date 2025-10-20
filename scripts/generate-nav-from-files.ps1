# Generate navigation structure based on actual files created
$baseDir = "docs"
$categories = @("getting-started", "activities", "reference", "tutorials")

Write-Host "Generating navigation based on actual files..." -ForegroundColor Green

# Start building the nav structure
$navContent = @"
nav:
  - Home: index.md
"@

foreach ($category in $categories) {
    $categoryPath = Join-Path $baseDir $category
    if (Test-Path $categoryPath) {
        $files = Get-ChildItem "$categoryPath\*.md" | Sort-Object Name
        
        if ($files.Count -gt 0) {
            # Add category header
            $categoryTitle = (Get-Culture).TextInfo.ToTitleCase($category.Replace("-", " "))
            $navContent += "`n  - ${categoryTitle}:"
            
            # Add files in this category
            foreach ($file in $files) {
                $filename = $file.Name
                $title = $filename -replace '\.md$', '' -replace '-', ' ' -replace '---', ' - '
                $title = (Get-Culture).TextInfo.ToTitleCase($title)
                $relativePath = "$category/$filename"
                $navContent += "`n    - `"$title`": $relativePath"
            }
        }
    }
}

# Read the current mkdocs.yml to preserve the header
$currentConfig = Get-Content "mkdocs.yml" -Raw
$headerEnd = $currentConfig.IndexOf("nav:")
$header = $currentConfig.Substring(0, $headerEnd).Trim()

# Combine header with new nav
$newConfig = $header + "`n`n" + $navContent

# Write the new configuration
$newConfig | Set-Content "mkdocs.yml" -Encoding UTF8

Write-Host "Navigation updated in mkdocs.yml" -ForegroundColor Green
Write-Host "Categories processed:" -ForegroundColor Yellow
foreach ($category in $categories) {
    $count = (Get-ChildItem "docs\$category\*.md" -ErrorAction SilentlyContinue).Count
    Write-Host "  ${category}: $count files" -ForegroundColor Cyan
}