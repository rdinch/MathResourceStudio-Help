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

# Function to remove paragraph tags
function Remove-ParagraphTags {
    param([string]$content)
    
    $modified = $false
    $newContent = $content
    
    # Count occurrences before removal
    $pOpenCount = ([regex]::Matches($newContent, '<p[^>]*>')).Count
    $pCloseCount = ([regex]::Matches($newContent, '</p>')).Count
    
    if ($pOpenCount -gt 0 -or $pCloseCount -gt 0) {
        # Remove opening paragraph tags (including any attributes)
        $newContent = $newContent -replace '<p[^>]*>', ''
        
        # Remove closing paragraph tags
        $newContent = $newContent -replace '</p>', ''
        
        # Clean up any extra whitespace that might result
        # Replace multiple consecutive newlines with just two (paragraph spacing)
        $newContent = $newContent -replace '\n\s*\n\s*\n+', "`n`n"
        
        # Clean up any trailing/leading whitespace on lines
        $lines = $newContent -split "`n"
        $cleanedLines = $lines | ForEach-Object { $_.TrimEnd() }
        $newContent = $cleanedLines -join "`n"
        
        $modified = $true
        
        if ($Verbose) {
            Write-Log "Removed $pOpenCount opening <p> tags and $pCloseCount closing </p> tags" -Level "VERBOSE"
        }
    }
    
    return @{
        Content = $newContent
        Modified = $modified
        OpenTagsRemoved = $pOpenCount
        CloseTagsRemoved = $pCloseCount
    }
}

try {
    Write-Log "Starting paragraph tag removal script"
    Write-Log "Target path: $Path"
    Write-Log "WhatIf mode: $WhatIf"
    
    # Get all markdown files
    $markdownFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" | Where-Object { !$_.PSIsContainer }
    Write-Log "Found $($markdownFiles.Count) markdown files to process"
    
    $filesProcessed = 0
    $filesModified = 0
    $errorsEncountered = 0
    $totalOpenTagsRemoved = 0
    $totalCloseTagsRemoved = 0
    
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
            
            # Remove paragraph tags
            $result = Remove-ParagraphTags -content $content
            
            if ($result.Modified) {
                if ($WhatIf) {
                    Write-Log "WOULD MODIFY: $($file.FullName) (Remove $($result.OpenTagsRemoved) <p> and $($result.CloseTagsRemoved) </p> tags)" -Level "WHATIF"
                } else {
                    # Write the modified content back to the file
                    Set-Content -Path $file.FullName -Value $result.Content -Encoding UTF8 -NoNewline
                    Write-Log "Modified: $($file.FullName) (Removed $($result.OpenTagsRemoved) <p> and $($result.CloseTagsRemoved) </p> tags)" -Level "SUCCESS"
                }
                $filesModified++
                $totalOpenTagsRemoved += $result.OpenTagsRemoved
                $totalCloseTagsRemoved += $result.CloseTagsRemoved
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
    Write-Log "Total <p> tags removed: $totalOpenTagsRemoved"
    Write-Log "Total </p> tags removed: $totalCloseTagsRemoved"
    Write-Log "Errors encountered: $errorsEncountered"
    
    if ($WhatIf) {
        Write-Log "This was a dry run. Use -WhatIf:`$false to actually make changes."
    }
    
} catch {
    Write-Log "Script failed with error: $($_.Exception.Message)" -Level "ERROR"
    exit 1
}