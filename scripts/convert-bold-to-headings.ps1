param(
    [switch]$WhatIf = $false
)

Write-Host "[INFO] Starting conversion of bold text to H3 headings" -ForegroundColor Cyan
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
        
        # Pattern: Bold text on its own line (may have leading/trailing whitespace)
        # This matches: **Some Text** on a line by itself
        # (?m) = multiline mode
        # ^\s* = optional leading whitespace
        # \*\*([^\*\n]+)\*\* = bold text (capturing the content without asterisks)
        # \s*$ = optional trailing whitespace and end of line
        $pattern = '(?m)^\s*\*\*([^\*\n]+)\*\*\s*$'
        
        # Count matches in this file
        $matches = [regex]::Matches($content, $pattern)
        
        if ($matches.Count -gt 0) {
            # Replace with H3 heading
            $newContent = $content -replace $pattern, '### $1'
            
            if ($newContent -ne $content) {
                if (-not $WhatIf) {
                    Set-Content -Path $file.FullName -Value $newContent -NoNewline
                    Write-Host "[SUCCESS] Modified: $($file.Name) - $($matches.Count) replacement(s)" -ForegroundColor Green
                } else {
                    Write-Host "[WHATIF] Would modify: $($file.Name) - $($matches.Count) replacement(s)" -ForegroundColor Yellow
                }
                $modifiedCount++
                $totalReplacements += $matches.Count
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
Write-Host "[INFO] Bold to H3 heading conversion completed!" -ForegroundColor Cyan
Write-Host "[INFO] Files scanned: $($markdownFiles.Count)" -ForegroundColor Cyan
if ($modifiedCount -gt 0) {
    Write-Host "[SUCCESS] Files modified: $modifiedCount" -ForegroundColor Green
    Write-Host "[SUCCESS] Total replacements: $totalReplacements" -ForegroundColor Green
}
if ($errorCount -gt 0) {
    Write-Host "[ERROR] Errors encountered: $errorCount" -ForegroundColor Red
}
Write-Host "[INFO] ===============================================" -ForegroundColor Cyan
