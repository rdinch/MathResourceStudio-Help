# PowerShell script to remove empty table structures from markdown files
# This script removes various patterns of empty or nearly empty HTML tables

param(
    [string]$Path = "docs",
    [switch]$WhatIf = $false,
    [switch]$Verbose = $false
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Remove-EmptyTables {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Encoding UTF8 -Raw
        $originalContent = $content
        $modified = $false
        
        # Pattern 1: Completely empty tables
        # <table><tbody><tr></tr></tbody></table> (with any whitespace)
        $pattern1 = '<table>\s*<tbody>\s*<tr>\s*</tr>\s*</tbody>\s*</table>'
        if ($content -match $pattern1) {
            $content = $content -replace $pattern1, ''
            $modified = $true
            if ($Verbose) {
                Write-Log "Removed empty table pattern 1 from $FilePath" "VERBOSE"
            }
        }
        
        # Pattern 2: Empty tables with multiple empty rows
        $pattern2 = '<table>\s*<tbody>\s*(?:<tr>\s*</tr>\s*)*</tbody>\s*</table>'
        if ($content -match $pattern2) {
            $content = $content -replace $pattern2, ''
            $modified = $true
            if ($Verbose) {
                Write-Log "Removed empty table pattern 2 from $FilePath" "VERBOSE"
            }
        }
        
        # Pattern 3: Tables with only empty cells
        $pattern3 = '<table>\s*<tbody>\s*<tr>\s*(?:<td>\s*</td>\s*)*</tr>\s*</tbody>\s*</table>'
        if ($content -match $pattern3) {
            $content = $content -replace $pattern3, ''
            $modified = $true
            if ($Verbose) {
                Write-Log "Removed empty table pattern 3 from $FilePath" "VERBOSE"
            }
        }
        
        # Pattern 4: Clean up multiple consecutive blank lines left after table removal
        $content = $content -replace '\n\s*\n\s*\n', "`n`n"
        
        # Pattern 5: Clean up leading/trailing whitespace on lines
        $lines = $content -split "`n"
        $cleanedLines = @()
        foreach ($line in $lines) {
            $cleanedLines += $line.TrimEnd()
        }
        $content = $cleanedLines -join "`n"
        
        # Check if content actually changed
        if ($content -ne $originalContent) {
            $modified = $true
        }
        
        if ($modified) {
            if ($WhatIf) {
                Write-Log "WOULD MODIFY: $FilePath" "WHATIF"
            } else {
                # Write the modified content back to file
                $content | Set-Content -Path $FilePath -Encoding UTF8 -NoNewline
                Write-Log "Modified: $FilePath" "SUCCESS"
            }
            return $true
        } else {
            if ($Verbose) {
                Write-Log "No changes needed: $FilePath" "VERBOSE"
            }
            return $false
        }
    }
    catch {
        Write-Log "Error processing $FilePath`: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

# Main script execution
Write-Log "Starting empty table removal script"
Write-Log "Target path: $Path"
Write-Log "WhatIf mode: $WhatIf"

if (-not (Test-Path $Path)) {
    Write-Log "Path '$Path' does not exist!" "ERROR"
    exit 1
}

# Find all markdown files
$markdownFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" | Where-Object { -not $_.PSIsContainer }

Write-Log "Found $($markdownFiles.Count) markdown files to process"

$modifiedCount = 0
$errorCount = 0

foreach ($file in $markdownFiles) {
    if ($Verbose) {
        Write-Log "Processing: $($file.FullName)" "VERBOSE"
    }
    
    $result = Remove-EmptyTables -FilePath $file.FullName
    if ($result -eq $true) {
        $modifiedCount++
    } elseif ($result -eq $false -and $Error.Count -gt 0) {
        $errorCount++
    }
}

Write-Log "Script completed"
Write-Log "Files processed: $($markdownFiles.Count)"
Write-Log "Files modified: $modifiedCount"
Write-Log "Errors encountered: $errorCount"

if ($WhatIf) {
    Write-Log "This was a dry run. Use -WhatIf:`$false to actually make changes." "INFO"
}