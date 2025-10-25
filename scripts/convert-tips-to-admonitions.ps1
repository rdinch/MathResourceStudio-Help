# Script to convert "TIP:" lines to proper !!! tip admonitions
# Converts: TIP: Some text here
# To:       !!! tip
#               Some text here

param(
    [string]$Path = "docs",
    [switch]$WhatIf = $false
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $colors = @{
        "INFO" = "White"
        "SUCCESS" = "Green"
        "WARNING" = "Yellow"
        "ERROR" = "Red"
        "WHATIF" = "Cyan"
    }
    Write-Host "[$Level] $Message" -ForegroundColor $colors[$Level]
}

Write-Log "Starting TIP to admonition conversion" -Level "INFO"
Write-Log "Target path: $Path" -Level "INFO"
Write-Log "WhatIf mode: $WhatIf" -Level "INFO"
Write-Host ""

# Get all markdown files
$markdownFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" | Where-Object { !$_.PSIsContainer }
Write-Log "Found $($markdownFiles.Count) markdown files to scan" -Level "INFO"
Write-Host ""

$filesProcessed = 0
$filesModified = 0
$totalTipsConverted = 0
$errorsEncountered = 0

foreach ($file in $markdownFiles) {
    try {
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        if ($null -eq $content) {
            continue
        }
        
        # Check if file contains TIP: pattern
        if ($content -notmatch '(?m)^TIP:') {
            continue
        }
        
        $originalContent = $content
        $tipsInFile = 0
        
        # Convert TIP: lines to admonitions
        # Pattern: Start of line, "TIP:", optional space, then the rest of the line
        # Replace with: !!! tip, newline, 4 spaces, then the rest of the line
        $newContent = $content -replace '(?m)^TIP:\s*(.+)$', "!!! tip`n    `$1"
        
        # Count how many replacements were made
        $tipsInFile = ([regex]::Matches($originalContent, '(?m)^TIP:')).Count
        
        if ($newContent -ne $originalContent) {
            if ($WhatIf) {
                Write-Log "WOULD MODIFY: $($file.FullName) ($tipsInFile tips)" -Level "WHATIF"
            } else {
                # Write the modified content back to the file
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
                Write-Log "Modified: $($file.Name) ($tipsInFile tips converted)" -Level "SUCCESS"
            }
            $filesModified++
            $totalTipsConverted += $tipsInFile
        }
        
        $filesProcessed++
        
    } catch {
        Write-Log "Error processing file $($file.FullName): $($_.Exception.Message)" -Level "ERROR"
        $errorsEncountered++
    }
}

Write-Host ""
Write-Log "===============================================" -Level "INFO"
Write-Log "Conversion completed!" -Level "INFO"
Write-Log "Files scanned: $filesProcessed" -Level "INFO"
Write-Log "Files modified: $filesModified" -Level "SUCCESS"
Write-Log "Total TIPs converted: $totalTipsConverted" -Level "SUCCESS"
Write-Log "Errors encountered: $errorsEncountered" -Level $(if($errorsEncountered -gt 0){"ERROR"}else{"INFO"})
Write-Log "===============================================" -Level "INFO"

if ($WhatIf) {
    Write-Host ""
    Write-Log "This was a dry run. Run without -WhatIf to actually make changes." -Level "WARNING"
}
