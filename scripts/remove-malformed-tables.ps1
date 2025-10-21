param(
    [string]$Path = "docs",
    [switch]$WhatIf = $false,
    [switch]$Verbose = $false
)

# Function to write timestamped log messages
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
}

# Function to extract text content from paragraph tags
function Get-ParagraphContent {
    param([string]$htmlContent)
    
    # Remove paragraph tags but keep the content
    $cleaned = $htmlContent -replace '<p[^>]*>', '' -replace '</p>', "`n"
    
    # Clean up extra whitespace and normalize line breaks
    $cleaned = $cleaned -replace '\s+', ' '
    $cleaned = $cleaned.Trim()
    
    return $cleaned
}

# Function to process malformed tables
function Remove-MalformedTables {
    param([string]$content)
    
    $modified = $false
    $newContent = $content
    
    # Pattern 1: Tables with only paragraph content (no actual table structure needed)
    # Matches: <table><tbody><tr><td><p>content</p>...</td></tr></tbody></table>
    $pattern1 = '<table[^>]*>\s*<tbody[^>]*>\s*<tr[^>]*>\s*<td[^>]*>(.*?)</td>\s*</tr>\s*</tbody>\s*</table>'
    
    if ($newContent -match $pattern1) {
        $newContent = $newContent -replace $pattern1, {
            param($match)
            $cellContent = $match.Groups[1].Value
            $extractedText = Get-ParagraphContent $cellContent
            if ($Verbose) {
                Write-Log "Removed malformed table pattern 1, extracted: $($extractedText.Substring(0, [Math]::Min(50, $extractedText.Length)))..." -Level "VERBOSE"
            }
            return $extractedText
        }
        $modified = $true
    }
    
    # Pattern 2: More complex table structures with multiple cells
    # Matches: <table><tbody><tr><td>content</td><td>content</td></tr></tbody></table>
    $pattern2 = '<table[^>]*>\s*<tbody[^>]*>\s*<tr[^>]*>((?:\s*<td[^>]*>.*?</td>\s*)+)</tr>\s*</tbody>\s*</table>'
    
    if ($newContent -match $pattern2) {
        $newContent = $newContent -replace $pattern2, {
            param($match)
            $rowContent = $match.Groups[1].Value
            
            # Extract content from each cell
            $cellPattern = '<td[^>]*>(.*?)</td>'
            $cellMatches = [regex]::Matches($rowContent, $cellPattern)
            
            $extractedTexts = @()
            foreach ($cellMatch in $cellMatches) {
                $cellContent = $cellMatch.Groups[1].Value
                $extractedText = Get-ParagraphContent $cellContent
                if ($extractedText.Trim() -ne '') {
                    $extractedTexts += $extractedText
                }
            }
            
            $result = $extractedTexts -join "`n`n"
            if ($Verbose) {
                Write-Log "Removed malformed table pattern 2, extracted: $($result.Substring(0, [Math]::Min(50, $result.Length)))..." -Level "VERBOSE"
            }
            return $result
        }
        $modified = $true
    }
    
    # Pattern 3: Tables with thead/tbody structure containing only text
    $pattern3 = '<table[^>]*>\s*<thead[^>]*>.*?</thead>\s*<tbody[^>]*>(.*?)</tbody>\s*</table>'
    
    if ($newContent -match $pattern3) {
        $newContent = $newContent -replace $pattern3, {
            param($match)
            $bodyContent = $match.Groups[1].Value
            
            # Extract all cell content from the tbody
            $cellPattern = '<td[^>]*>(.*?)</td>'
            $cellMatches = [regex]::Matches($bodyContent, $cellPattern)
            
            $extractedTexts = @()
            foreach ($cellMatch in $cellMatches) {
                $cellContent = $cellMatch.Groups[1].Value
                $extractedText = Get-ParagraphContent $cellContent
                if ($extractedText.Trim() -ne '') {
                    $extractedTexts += $extractedText
                }
            }
            
            $result = $extractedTexts -join "`n`n"
            if ($Verbose) {
                Write-Log "Removed malformed table pattern 3, extracted: $($result.Substring(0, [Math]::Min(50, $result.Length)))..." -Level "VERBOSE"
            }
            return $result
        }
        $modified = $true
    }
    
    # Pattern 4: Simple tables that are just wrapping single paragraphs
    $pattern4 = '<table[^>]*>\s*<tbody[^>]*>\s*<tr[^>]*>\s*<td[^>]*>\s*<p[^>]*>(.*?)</p>\s*</td>\s*</tr>\s*</tbody>\s*</table>'
    
    if ($newContent -match $pattern4) {
        $newContent = $newContent -replace $pattern4, '$1'
        $modified = $true
        if ($Verbose) {
            Write-Log "Removed malformed table pattern 4 (simple paragraph wrapper)" -Level "VERBOSE"
        }
    }
    
    return @{
        Content = $newContent
        Modified = $modified
    }
}

try {
    Write-Log "Starting malformed table removal script"
    Write-Log "Target path: $Path"
    Write-Log "WhatIf mode: $WhatIf"
    
    # Get all markdown files
    $markdownFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" | Where-Object { !$_.PSIsContainer }
    Write-Log "Found $($markdownFiles.Count) markdown files to process"
    
    $filesProcessed = 0
    $filesModified = 0
    $errorsEncountered = 0
    
    foreach ($file in $markdownFiles) {
        try {
            if ($Verbose) {
                Write-Log "Processing: $($file.FullName)" -Level "VERBOSE"
            }
            
            # Read file content
            $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
            
            if ($null -eq $content) {
                continue
            }
            
            # Process malformed tables
            $result = Remove-MalformedTables -content $content
            
            if ($result.Modified) {
                if ($WhatIf) {
                    Write-Log "WOULD MODIFY: $($file.FullName)" -Level "WHATIF"
                } else {
                    # Write the modified content back to the file
                    Set-Content -Path $file.FullName -Value $result.Content -Encoding UTF8 -NoNewline
                    Write-Log "Modified: $($file.FullName)" -Level "SUCCESS"
                }
                $filesModified++
            }
            
            $filesProcessed++
            
        } catch {
            Write-Log "Error processing file $($file.FullName): $($_.Exception.Message)" -Level "ERROR"
            $errorsEncountered++
        }
    }
    
    Write-Log "Script completed"
    Write-Log "Files processed: $filesProcessed"
    Write-Log "Files modified: $filesModified"
    Write-Log "Errors encountered: $errorsEncountered"
    
    if ($WhatIf) {
        Write-Log "This was a dry run. Use -WhatIf:`$false to actually make changes."
    }
    
} catch {
    Write-Log "Script failed with error: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}