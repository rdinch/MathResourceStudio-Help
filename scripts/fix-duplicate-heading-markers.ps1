param(
    [switch]$WhatIf = $false
)

Write-Host "[INFO] Starting duplicate heading marker fix" -ForegroundColor Cyan
Write-Host "[INFO] Target path: docs" -ForegroundColor Cyan
Write-Host "[INFO] WhatIf mode: $WhatIf" -ForegroundColor Cyan
Write-Host ""

# Get all markdown files recursively
$markdownFiles = Get-ChildItem -Path "docs" -Filter "*.md" -Recurse -File

Write-Host "[INFO] Found $($markdownFiles.Count) markdown files to scan" -ForegroundColor Cyan
Write-Host ""

$modifiedCount = 0
$errorCount = 0
$totalReplacements = 0

foreach ($file in $markdownFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        $originalContent = $content
        
        # Pattern to match multiple ## (with or without spaces between them) at the start of a line
        # This handles cases like "## ##" or "## ## ##" etc.
        # We replace with single "##" followed by space
        $pattern = '(?m)^(##\s+)+(##\s+)'
        
        $fileReplacements = 0
        
        # Keep replacing until no more duplicates are found
        while ($content -match $pattern) {
            $beforeReplace = $content
            $content = $content -replace $pattern, '## '
            if ($content -eq $beforeReplace) {
                break  # Prevent infinite loop
            }
            $fileReplacements++
        }
        
        if ($content -ne $originalContent) {
            if (-not $WhatIf) {
                Set-Content -Path $file.FullName -Value $content -NoNewline
                Write-Host "[SUCCESS] Modified: $($file.Name)" -ForegroundColor Green
            } else {
                Write-Host "[WHATIF] Would modify: $($file.Name)" -ForegroundColor Yellow
            }
            $modifiedCount++
            $totalReplacements += $fileReplacements
        }
    }
    catch {
        Write-Host "[ERROR] Failed to process $($file.Name): $_" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "[INFO] ===============================================" -ForegroundColor Cyan
Write-Host "[INFO] Duplicate heading marker fix completed!" -ForegroundColor Cyan
Write-Host "[INFO] Files scanned: $($markdownFiles.Count)" -ForegroundColor Cyan
if ($modifiedCount -gt 0) {
    Write-Host "[SUCCESS] Files modified: $modifiedCount" -ForegroundColor Green
    Write-Host "[SUCCESS] Total replacements: $totalReplacements" -ForegroundColor Green
}
if ($errorCount -gt 0) {
    Write-Host "[ERROR] Errors encountered: $errorCount" -ForegroundColor Red
}
Write-Host "[INFO] ===============================================" -ForegroundColor Cyan
