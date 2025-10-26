# Script to remove the "category:" line from YAML front matter in all markdown files

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

Write-Log "Starting category field removal from YAML front matter" -Level "INFO"
Write-Log "Target path: $Path" -Level "INFO"
Write-Log "WhatIf mode: $WhatIf" -Level "INFO"
Write-Host ""

# Get all markdown files
$markdownFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" | Where-Object { !$_.PSIsContainer }
Write-Log "Found $($markdownFiles.Count) markdown files to scan" -Level "INFO"
Write-Host ""

$filesProcessed = 0
$filesModified = 0
$errorsEncountered = 0

foreach ($file in $markdownFiles) {
    try {
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        if ($null -eq $content) {
            continue
        }
        
        # Check if file has category line
        if ($content -notmatch '(?m)^category:') {
            continue
        }
        
        $originalContent = $content
        
        # Remove the category line (including the newline)
        $newContent = $content -replace '(?m)^category:.*\r?\n', ''
        
        if ($newContent -ne $originalContent) {
            if ($WhatIf) {
                Write-Log "WOULD MODIFY: $($file.FullName)" -Level "WHATIF"
            } else {
                # Write the modified content back to the file
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
                Write-Log "Modified: $($file.Name)" -Level "SUCCESS"
            }
            $filesModified++
        }
        
        $filesProcessed++
        
    } catch {
        Write-Log "Error processing file $($file.FullName): $($_.Exception.Message)" -Level "ERROR"
        $errorsEncountered++
    }
}

Write-Host ""
Write-Log "===============================================" -Level "INFO"
Write-Log "Category field removal completed!" -Level "INFO"
Write-Log "Files scanned: $filesProcessed" -Level "INFO"
Write-Log "Files modified: $filesModified" -Level "SUCCESS"
Write-Log "Errors encountered: $errorsEncountered" -Level $(if($errorsEncountered -gt 0){"ERROR"}else{"INFO"})
Write-Log "===============================================" -Level "INFO"

if ($WhatIf) {
    Write-Host ""
    Write-Log "This was a dry run. Run without -WhatIf to actually make changes." -Level "WARNING"
}
