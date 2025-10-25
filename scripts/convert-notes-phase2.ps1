# Script to convert "NOTE:" and "NOTES:" with bullet lists to proper !!! note admonitions
# Phase 2: Handles notes followed by bullet lists
# Converts: NOTE: Some text
#           
#           - bullet 1
#           - bullet 2
# To:       !!! note
#               Some text
#               
#               - bullet 1
#               - bullet 2

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

Write-Log "Starting NOTE/NOTES to admonition conversion (Phase 2 - Notes with Bullet Lists)" -Level "INFO"
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
        
        # Split content into lines for processing
        $lines = $content -split "`n"
        $newLines = @()
        
        for ($i = 0; $i -lt $lines.Count; $i++) {
            $line = $lines[$i]
            
            # Check if this line starts with NOTE: or NOTES:
            if ($line -match '^(NOTE|NOTES):\s*(.+)$') {
                $noteText = $matches[2]
                
                # Check if this note has a bullet list following it
                $hasBulletList = $false
                $bulletStartIndex = -1
                
                # Check next line (might be blank or bullet)
                if ($i + 1 -lt $lines.Count) {
                    $nextLine = $lines[$i + 1].Trim()
                    if ($nextLine -match '^-\s+') {
                        $hasBulletList = $true
                        $bulletStartIndex = $i + 1
                    }
                }
                
                # If next line is blank, check the line after that
                if (-not $hasBulletList -and $i + 2 -lt $lines.Count) {
                    $nextLine = $lines[$i + 1].Trim()
                    $lineAfterNext = $lines[$i + 2].Trim()
                    if ($nextLine -eq '' -and $lineAfterNext -match '^-\s+') {
                        $hasBulletList = $true
                        $bulletStartIndex = $i + 2
                    }
                }
                
                # Only process if this note HAS a bullet list
                if ($hasBulletList) {
                    # Start the admonition
                    $newLines += "!!! note"
                    $newLines += "    $noteText"
                    
                    # Add blank line if there was one between NOTE and bullets
                    if ($bulletStartIndex -eq $i + 2) {
                        $newLines += ""
                    }
                    
                    # Find all consecutive bullet lines and indent them
                    $j = $bulletStartIndex
                    while ($j -lt $lines.Count) {
                        $bulletLine = $lines[$j]
                        
                        # If it's a bullet line, indent it
                        if ($bulletLine -match '^-\s+') {
                            $newLines += "    $bulletLine"
                            $j++
                        }
                        # If it's a blank line, check if next line is also a bullet
                        elseif ($bulletLine.Trim() -eq '' -and $j + 1 -lt $lines.Count -and $lines[$j + 1] -match '^-\s+') {
                            $newLines += ""
                            $j++
                        }
                        # End of bullet list
                        else {
                            break
                        }
                    }
                    
                    # Skip ahead past the bullets we just processed
                    $i = $j - 1
                    $notesInFile++
                } else {
                    # No bullet list - should have been handled in Phase 1
                    $newLines += $line
                }
            } else {
                # Regular line, keep as-is
                $newLines += $line
            }
        }
        
        $newContent = $newLines -join "`n"
        
        if ($newContent -ne $originalContent -and $notesInFile -gt 0) {
            if ($WhatIf) {
                Write-Log "WOULD MODIFY: $($file.FullName) ($notesInFile notes with bullets)" -Level "WHATIF"
            } else {
                # Write the modified content back to the file
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
                Write-Log "Modified: $($file.Name) ($notesInFile notes with bullets converted)" -Level "SUCCESS"
            }
            $filesModified++
            $totalNotesConverted += $notesInFile
        }
        
        $filesProcessed++
        
    } catch {
        Write-Log "Error processing file $($file.FullName): $($_.Exception.Message)" -Level "ERROR"
        $errorsEncountered++
    }
}

Write-Host ""
Write-Log "===============================================" -Level "INFO"
Write-Log "Phase 2 Conversion completed!" -Level "INFO"
Write-Log "Files scanned: $filesProcessed" -Level "INFO"
Write-Log "Files modified: $filesModified" -Level "SUCCESS"
Write-Log "Total NOTEs with bullets converted: $totalNotesConverted" -Level "SUCCESS"
Write-Log "Errors encountered: $errorsEncountered" -Level $(if($errorsEncountered -gt 0){"ERROR"}else{"INFO"})
Write-Log "===============================================" -Level "INFO"

if ($WhatIf) {
    Write-Host ""
    Write-Log "This was a dry run. Run without -WhatIf to actually make changes." -Level "WARNING"
}
