param(
    [switch]$WhatIf = $false
)

Write-Host "[INFO] Starting YAML front matter removal" -ForegroundColor Cyan
Write-Host "[INFO] Target path: docs" -ForegroundColor Cyan
Write-Host "[INFO] WhatIf mode: $WhatIf" -ForegroundColor Cyan
Write-Host ""

# Get all markdown files recursively
$markdownFiles = Get-ChildItem -Path "docs" -Filter "*.md" -Recurse -File

Write-Host "[INFO] Found $($markdownFiles.Count) markdown files to scan" -ForegroundColor Cyan
Write-Host ""

$modifiedCount = 0
$errorCount = 0

foreach ($file in $markdownFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Check if file starts with YAML front matter (--- at the beginning)
        if ($content -match '^---\r?\n') {
            # Remove YAML front matter block (from start to second ---)
            # Also remove any blank lines immediately after the front matter
            $newContent = $content -replace '^---\r?\n.*?\r?\n---\r?\n(\r?\n)*', ''
            
            if ($newContent -ne $content) {
                if (-not $WhatIf) {
                    Set-Content -Path $file.FullName -Value $newContent -NoNewline
                    Write-Host "[SUCCESS] Modified: $($file.Name)" -ForegroundColor Green
                } else {
                    Write-Host "[WHATIF] Would modify: $($file.Name)" -ForegroundColor Yellow
                }
                $modifiedCount++
            }
        }
    }
    catch {
        Write-Host "[ERROR] Failed to process $($file.Name): $_" -ForegroundColor Red
        $errorCount++
    }
}

Write-Host ""
Write-Host "[INFO] ===============================================" -ForegroundColor Cyan
Write-Host "[INFO] YAML front matter removal completed!" -ForegroundColor Cyan
Write-Host "[INFO] Files scanned: $($markdownFiles.Count)" -ForegroundColor Cyan
if ($modifiedCount -gt 0) {
    Write-Host "[SUCCESS] Files modified: $modifiedCount" -ForegroundColor Green
}
if ($errorCount -gt 0) {
    Write-Host "[ERROR] Errors encountered: $errorCount" -ForegroundColor Red
}
Write-Host "[INFO] ===============================================" -ForegroundColor Cyan
