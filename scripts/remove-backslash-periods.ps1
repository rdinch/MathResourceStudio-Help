# Script to remove unnecessary backslashes before periods in numbered lists
# This fixes the conversion artifact from CHM files where "1\." appears instead of "1."

$docsPath = Join-Path $PSScriptRoot "..\docs"

# Get all markdown files recursively
$markdownFiles = Get-ChildItem -Path $docsPath -Recurse -Filter "*.md"

Write-Host "Found $($markdownFiles.Count) markdown files" -ForegroundColor Cyan
Write-Host ""

$modifiedCount = 0
$totalReplacements = 0

foreach ($file in $markdownFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    
    if ([string]::IsNullOrWhiteSpace($content)) {
        continue
    }
    
    # Replace numbered list items with escaped periods (e.g., "1\." -> "1.")
    # This pattern matches: digit(s) followed by backslash and period at the start of a line or after whitespace
    $newContent = $content -replace '(\d)\\\.', '$1.'
    
    # Count how many replacements were made in this file
    $replacements = ([regex]::Matches($content, '\d\\\.')).Count
    
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        
        $relativePath = $file.FullName.Replace($docsPath + "\", "")
        Write-Host "  ✓ $relativePath - Fixed $replacements instances" -ForegroundColor Green
        
        $modifiedCount++
        $totalReplacements += $replacements
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Modified: $modifiedCount files" -ForegroundColor Green
Write-Host "Total replacements: $totalReplacements" -ForegroundColor Green
Write-Host ""
