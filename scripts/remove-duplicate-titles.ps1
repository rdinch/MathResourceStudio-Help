# PowerShell script to remove duplicate underlined bold titles from markdown files
# This script removes lines that match the pattern **<u>Title</u>** when they appear after H1 titles

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

function Remove-DuplicateTitle {
    param([string]$FilePath)
    
    try {
        $content = Get-Content -Path $FilePath -Encoding UTF8
        $modified = $false
        $newContent = @()
        
        for ($i = 0; $i -lt $content.Length; $i++) {
            $line = $content[$i]
            
            # Check if this line matches the pattern **<u>...</u>**
            if ($line -match '^\*\*<u>.*</u>\*\*$') {
                # Check if this appears to be a duplicate title
                # Look for an H1 title in the preceding lines (within reasonable distance)
                $isDuplicate = $false
                
                # Check previous lines (up to 10 lines back) for H1 title
                for ($j = [Math]::Max(0, $i - 10); $j -lt $i; $j++) {
                    if ($content[$j] -match '^# (.+)$') {
                        $h1Title = $matches[1].Trim()
                        # Extract the title from the underlined version
                        if ($line -match '^\*\*<u>(.+)</u>\*\*$') {
                            $underlinedTitle = $matches[1].Trim()
                            
                            # Compare titles (case-insensitive, allowing for minor differences)
                            if ($h1Title -eq $underlinedTitle) {
                                $isDuplicate = $true
                                if ($Verbose) {
                                    Write-Log "Found duplicate title in $FilePath at line $($i + 1): '$line'" "VERBOSE"
                                }
                                break
                            }
                        }
                    }
                }
                
                if ($isDuplicate) {
                    $modified = $true
                    if ($Verbose) {
                        Write-Log "Removing duplicate title: '$line'" "VERBOSE"
                    }
                    # Skip this line (don't add to newContent)
                    continue
                }
            }
            
            # Add the line to new content
            $newContent += $line
        }
        
        if ($modified) {
            if ($WhatIf) {
                Write-Log "WOULD MODIFY: $FilePath" "WHATIF"
            } else {
                # Write the modified content back to file
                $newContent | Set-Content -Path $FilePath -Encoding UTF8
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
Write-Log "Starting duplicate title removal script"
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
    
    $result = Remove-DuplicateTitle -FilePath $file.FullName
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