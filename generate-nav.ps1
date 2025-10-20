# PowerShell script to generate MkDocs navigation structure
# Automatically creates nav entries for all split files

$docsDir = ".\docs"
$outputFile = "mkdocs-nav.yml"

Write-Host "Generating MkDocs navigation structure..." -ForegroundColor Green

function Get-FileTitle {
    param($filePath)
    
    # Read the title from the front matter
    $content = Get-Content $filePath -Raw
    if ($content -match '---\s*title:\s*([^\n]+)') {
        return $matches[1].Trim()
    }
    
    # Fallback: Convert filename to title
    $name = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
    $title = $name -replace '-', ' '
    $title = (Get-Culture).TextInfo.ToTitleCase($title.ToLower())
    return $title
}

function Get-NavigationForDirectory {
    param($dirPath, $dirName)
    
    $files = Get-ChildItem $dirPath -Filter "*.md" | Sort-Object Name
    $entries = @()
    
    foreach ($file in $files) {
        $title = Get-FileTitle $file.FullName
        $relativePath = "$dirName/$($file.Name)"
        $entries += "  - '$title': '$relativePath'"
    }
    
    return $entries
}

$navContent = @"
site_name: Math Resource Studio Help
site_url: https://rdinch.github.io/MathResourceStudio-Help/
site_description: Complete help documentation for Math Resource Studio 8

theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.highlight
    - search.share
    - content.code.copy
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: blue
      accent: blue
      toggle:
        icon: material/weather-sunny
        name: Switch to dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: blue
      accent: blue
      toggle:
        icon: material/weather-night
        name: Switch to light mode

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - pymdownx.tabbed:
      alternate_style: true
  - attr_list
  - md_in_html

nav:
  - Home: index.md
  - Getting Started:
"@

# Add Getting Started files
$gettingStartedFiles = Get-NavigationForDirectory (Join-Path $docsDir "getting-started") "getting-started"
foreach ($entry in $gettingStartedFiles) {
    $navContent += "`n$entry"
}

$navContent += "`n  - Tutorials:"

# Add Tutorial files
$tutorialFiles = Get-NavigationForDirectory (Join-Path $docsDir "tutorials") "tutorials"
foreach ($entry in $tutorialFiles) {
    $navContent += "`n$entry"
}

$navContent += "`n  - Activities:"
$navContent += "`n    - Basic Operations:"

# Basic Math Activities
$basicActivities = @(
    "basic-addition.md", "basic-addition---doubles.md", "basic-addition-fixed-addend.md", "basic-addition-and-regrouping.md",
    "basic-subtraction.md", "basic-subtraction-and-regrouping.md", 
    "basic-multiplication.md", "basic-multiplication-fixed-factor.md",
    "basic-division.md"
)

foreach ($file in $basicActivities) {
    $filePath = Join-Path (Join-Path $docsDir "activities") $file
    if (Test-Path $filePath) {
        $title = Get-FileTitle $filePath
        $navContent += "`n      - '$title': 'activities/$file'"
    }
}

$navContent += "`n    - Advanced Operations:"

# Advanced Math Activities
$advancedActivities = Get-ChildItem (Join-Path $docsDir "activities") -Filter "advanced-*.md" | Sort-Object Name
foreach ($file in $advancedActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Fractions:"

# Fraction Activities
$fractionActivities = Get-ChildItem (Join-Path $docsDir "activities") -Filter "*fraction*.md" | Sort-Object Name
foreach ($file in $fractionActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Money & Time:"

# Money and Time Activities
$moneyTimeActivities = Get-ChildItem (Join-Path $docsDir "activities") | Where-Object { $_.Name -match "money|time|telling-time|time-" } | Sort-Object Name
foreach ($file in $moneyTimeActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Measurement & Geometry:"

# Measurement Activities
$measurementActivities = Get-ChildItem (Join-Path $docsDir "activities") | Where-Object { $_.Name -match "measurement|geometry|number-lines" } | Sort-Object Name
foreach ($file in $measurementActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Ratio & Percent:"

# Ratio and Percent Activities
$ratioPercentActivities = Get-ChildItem (Join-Path $docsDir "activities") | Where-Object { $_.Name -match "ratio|percent" } | Sort-Object Name
foreach ($file in $ratioPercentActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Algebra:"

# Algebra Activities
$algebraActivities = Get-ChildItem (Join-Path $docsDir "activities") | Where-Object { $_.Name -match "algebra|pre-algebra" } | Sort-Object Name
foreach ($file in $algebraActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Word Problems:"

# Word Problem Activities
$wordProblemActivities = Get-ChildItem (Join-Path $docsDir "activities") | Where-Object { $_.Name -match "word-problems" } | Sort-Object Name
foreach ($file in $wordProblemActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Drills & Tables:"

# Drill Activities
$drillActivities = Get-ChildItem (Join-Path $docsDir "activities") | Where-Object { $_.Name -match "drill|table-|circle-|box" } | Sort-Object Name
foreach ($file in $drillActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n    - Other Activities:"

# Remaining Activities
$allActivityFiles = Get-ChildItem (Join-Path $docsDir "activities") -Filter "*.md"
$categorizedFiles = @(
    $basicActivities + 
    $advancedActivities.Name + 
    $fractionActivities.Name + 
    $moneyTimeActivities.Name + 
    $measurementActivities.Name + 
    $ratioPercentActivities.Name + 
    $algebraActivities.Name + 
    $wordProblemActivities.Name + 
    $drillActivities.Name
)

$otherActivities = $allActivityFiles | Where-Object { $_.Name -notin $categorizedFiles } | Sort-Object Name
foreach ($file in $otherActivities) {
    $title = Get-FileTitle $file.FullName
    $navContent += "`n      - '$title': 'activities/$($file.Name)'"
}

$navContent += "`n  - Reference:"

# Add Reference files
$referenceFiles = Get-NavigationForDirectory (Join-Path $docsDir "reference") "reference"
foreach ($entry in $referenceFiles) {
    $navContent += "`n$entry"
}

$navContent += "`n  - Worksheets:"
$navContent += "`n    - Creating: worksheets/creating.md"
$navContent += "`n    - Properties: worksheets/properties.md"
$navContent += "`n    - Answer Sheets: worksheets/answer-sheets.md"

# Write the navigation file
Set-Content -Path $outputFile -Value $navContent -Encoding UTF8

Write-Host "Navigation structure generated: $outputFile" -ForegroundColor Green
Write-Host "Total sections: Activities (76), Reference (131), Tutorials (16), Getting Started (9)" -ForegroundColor Cyan