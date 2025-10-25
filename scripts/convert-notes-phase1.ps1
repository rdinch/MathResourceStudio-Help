# Script to convert simple "NOTE:" and "NOTES:" lines to proper !!! note admonitions
# Phase 1: Only converts single-line notes (not followed by bullet lists)
# Converts: NOTE: Some text here
# To:       !!! note
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

Write-Log "Starting NOTE/NOTES to admonition conversion (Phase 1 - Simple Notes Only)" -Level "INFO"
Write-Log "Target path: $Path" -Level "INFO"
Write-Log "WhatIf mode: $WhatIf" -Level "INFO"
Write-Host ""

# Get all markdown files
$markdownFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" | Where-Object { !$_.PSIsContainer }
Write-Log "Found $($markdownFiles.Count) markdown files to scan" -Level "INFO"
Write-Host ""

$filesProcessed = 0
$filesModified = 0
$totalNotesConverted = 0
$totalNotesSkipped = 0
$errorsEncountered = 0

foreach ($file in $markdownFiles) {
    try {
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        if ($null -eq $content) {
            continue
        }
        
        # Check if file contains NOTE: or NOTES: pattern
        if ($content -notmatch '(?m)^NOTES?:') {
            continue
        }
        
        $originalContent = $content
        $notesInFile = 0
        $skippedInFile = 0
        
        # Split content into lines for processing
        $lines = $content -split "`n"
        $newLines = @()
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            
            # Check if this line starts with NOTE: or NOTES:
            if ($line -match '^(NOTE|NOTES):\s*(.+)$') {
                $noteText = $matches[2]
                
                # Check if next line or the line after a blank line is a bullet point
                $hasBulletList = $false
                
                # Check next line (might be blank or bullet)
                if ($i + 1 -lt $lines.Count) {
                    $nextLine = $lines[$i + 1].Trim()
                    if ($nextLine -match '^-\s+') {
                        $hasBulletList = $true
                    }
                }
                
                # If next line is blank, check the line after that
                if (-not $hasBulletList -and $i + 2 -lt $lines.Count) {
                    $nextLine = $lines[$i + 1].Trim()
                    $lineAfterNext = $lines[$i + 2].Trim()
                    if ($nextLine -eq '' -and $lineAfterNext -match '^-\s+') {
                        $hasBulletList = $true
                    }
                }
                
                # Only convert if NOT followed by a bullet list
                if (-not $hasBulletList) {
                    # Convert to admonition format
                    $newLines += "!!! note"
                    $newLines += "    $noteText"
                    $notesInFile++
                } else {
                    # Skip this one - it has a bullet list (Phase 2)
                    $newLines += $line
                    $skippedInFile++
                }
            } else {
                # Regular line, keep as-is
                $newLines += $line
            }
        }
        
        $newContent = $newLines -join "`n"
        
        if ($newContent -ne $originalContent -and $notesInFile -gt 0) {
            if ($WhatIf) {
                Write-Log "WOULD MODIFY: $($file.FullName) ($notesInFile notes, $skippedInFile skipped)" -Level "WHATIF"
            } else {
                # Write the modified content back to the file
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
                Write-Log "Modified: $($file.Name) ($notesInFile notes converted, $skippedInFile skipped)" -Level "SUCCESS"
            }
            $filesModified++
            $totalNotesConverted += $notesInFile
            $totalNotesSkipped += $skippedInFile
        } elseif ($skippedInFile -gt 0) {
            Write-Log "Skipped: $($file.Name) (0 simple notes, $skippedInFile with bullets)" -Level "WARNING"
            $totalNotesSkipped += $skippedInFile
        }
        
        $filesProcessed++
        
    } catch {
        Write-Log "Error processing file $($file.FullName): $($_.Exception.Message)" -Level "ERROR"
        $errorsEncountered++
    }
}

Write-Host ""
Write-Log "===============================================" -Level "INFO"
Write-Log "Phase 1 Conversion completed!" -Level "INFO"
Write-Log "Files scanned: $filesProcessed" -Level "INFO"
Write-Log "Files modified: $filesModified" -Level "SUCCESS"
Write-Log "Total simple NOTEs converted: $totalNotesConverted" -Level "SUCCESS"
Write-Log "Total NOTEs skipped (with bullets): $totalNotesSkipped" -Level "WARNING"
Write-Log "Errors encountered: $errorsEncountered" -Level $(if($errorsEncountered -gt 0){"ERROR"}else{"INFO"})
Write-Log "===============================================" -Level "INFO"

if ($WhatIf) {
    Write-Host ""
    Write-Log "This was a dry run. Run without -WhatIf to actually make changes." -Level "WARNING"
}

if ($totalNotesSkipped -gt 0) {
    Write-Host ""
    Write-Log "NOTE: $totalNotesSkipped notes with bullet lists were skipped." -Level "INFO"
    Write-Log "These will be handled in Phase 2 with a separate script." -Level "INFO"
}
