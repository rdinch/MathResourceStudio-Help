# Add "Under Review" text in red below H1 headings in all markdown files
# This script adds a styled "Under Review" message after the first H1 heading

param(
    [string]$DocsPath = ".\docs",
    [switch]$TestMode = $false,
    [string]$TestFile = ""
)

$underReviewText = '<p style="color: red; font-weight: bold;">Under Review</p>'

function Add-UnderReviewText {
    param(
        [string]$FilePath
    )
    
    Write-Host "Processing: $FilePath"
    
    # Read the file content
    $content = Get-Content -Path $FilePath -Raw
    
    # Check if "Under Review" already exists to avoid duplicates
    if ($content -match "Under Review") {
        Write-Host "  Skipped: 'Under Review' already exists" -ForegroundColor Yellow
        return
    }
    
    # Pattern to match H1 heading (# Heading) followed by newline(s)
    # This will match: # Heading\n or # Heading\r\n
    $pattern = '(^#\s+[^\r\n]+)(\r?\n)'
    
    if ($content -match $pattern) {
        # Add the Under Review text after the H1 heading
        $newContent = $content -replace $pattern, "`$1`$2`n$underReviewText`n"
        
        # Write the modified content back to the file
        Set-Content -Path $FilePath -Value $newContent -NoNewline
        Write-Host "  Added 'Under Review' text" -ForegroundColor Green
    } else {
        Write-Host "  Skipped: No H1 heading found" -ForegroundColor Yellow
    }
}

# Main execution
if ($TestMode -and $TestFile) {
    # Test mode: process only the specified file
    Write-Host "Running in TEST MODE on file: $TestFile" -ForegroundColor Cyan
    Add-UnderReviewText -FilePath $TestFile
} else {
    # Process all markdown files in the docs directory
    Write-Host "Processing all markdown files in: $DocsPath" -ForegroundColor Cyan
    
    $markdownFiles = Get-ChildItem -Path $DocsPath -Filter "*.md" -Recurse
    $totalFiles = $markdownFiles.Count
    $processedCount = 0
    
    Write-Host "Found $totalFiles markdown files`n" -ForegroundColor Cyan
    
    foreach ($file in $markdownFiles) {
        $processedCount++
        Write-Host "[$processedCount/$totalFiles] " -NoNewline
        Add-UnderReviewText -FilePath $file.FullName
    }
    
    Write-Host "`nCompleted processing $totalFiles files!" -ForegroundColor Green
}
