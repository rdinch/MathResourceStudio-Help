param(
    [switch]$WhatIf = $false,
    [string]$Path = "docs"
)

Write-Host "[INFO] Starting section heading conversion" -ForegroundColor Cyan
Write-Host "[INFO] Target path: $Path" -ForegroundColor Cyan
Write-Host "[INFO] WhatIf mode: $WhatIf" -ForegroundColor Cyan
Write-Host ""

# Get all markdown files recursively
$markdownFiles = Get-ChildItem -Path $Path -Filter "*.md" -Recurse -File

Write-Host "[INFO] Found $($markdownFiles.Count) markdown files to scan" -ForegroundColor Cyan
Write-Host ""

$modifiedCount = 0
$errorCount = 0
$totalReplacements = 0

# Common section heading patterns that should become H2 headings
# These are on their own line and describe a section
$patterns = @(
    'Change the .+',
    'Set the .+',
    'Show the .+',
    'Show .+',
    'Select the .+',
    'Add the .+',
    'Remove the .+',
    'Enable the .+',
    'Disable the .+',
    'Choose the .+',
    'Specify the .+',
    'Define the .+',
    'Configure the .+'
)

foreach ($file in $markdownFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw
        $originalContent = $content
        $fileReplacements = 0
        
        foreach ($pattern in $patterns) {
            # Pattern explanation:
            # (?m) = multiline mode
            # ^(?!#) = start of line, NOT already a heading
            # ($pattern) = the pattern we're looking for (captured)
            # \s*\n\n? = consume trailing whitespace, newline, and optional second newline (blank line)
            $regex = "(?m)^(?!#)($pattern)\s*\n\n?"
            
            $matches = [regex]::Matches($content, $regex)
            
            if ($matches.Count -gt 0) {
                foreach ($match in $matches) {
                    $matchedText = $match.Groups[1].Value
                    # Only convert to heading if 50 characters or less (typical heading length)
                    if ($matchedText.Length -le 50) {
                        # Replace with H2 heading followed by exactly one blank line (two newlines total)
                        $content = $content -replace [regex]::Escape($match.Value), "## $matchedText`n`n"
                        $fileReplacements++
                    }
                }
            }
        }
        
        if ($content -ne $originalContent) {
            if (-not $WhatIf) {
                Set-Content -Path $file.FullName -Value $content -NoNewline
                Write-Host "[SUCCESS] Modified: $($file.Name) - $fileReplacements replacement(s)" -ForegroundColor Green
            } else {
                Write-Host "[WHATIF] Would modify: $($file.Name) - $fileReplacements replacement(s)" -ForegroundColor Yellow
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
Write-Host "[INFO] Section heading conversion completed!" -ForegroundColor Cyan
Write-Host "[INFO] Files scanned: $($markdownFiles.Count)" -ForegroundColor Cyan
if ($modifiedCount -gt 0) {
    Write-Host "[SUCCESS] Files modified: $modifiedCount" -ForegroundColor Green
    Write-Host "[SUCCESS] Total replacements: $totalReplacements" -ForegroundColor Green
}
if ($errorCount -gt 0) {
    Write-Host "[ERROR] Errors encountered: $errorCount" -ForegroundColor Red
}
Write-Host "[INFO] ===============================================" -ForegroundColor Cyan
