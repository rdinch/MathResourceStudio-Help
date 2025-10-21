param(
    [string]$TargetPath = "docs",
    [switch]$WhatIf = $false
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Remove-TableWrappers {
    param(
        [string]$Content
    )
    
    $originalContent = $Content
    $openingTagsRemoved = 0
    $closingTagsRemoved = 0
    
    # Remove table opening tags (table, tbody, tr, td with any attributes)
    $Content = $Content -replace '<table[^>]*>', ''
    $openingTagsRemoved += ([regex]::Matches($originalContent, '<table[^>]*>')).Count
    
    $Content = $Content -replace '<tbody[^>]*>', ''
    $openingTagsRemoved += ([regex]::Matches($originalContent, '<tbody[^>]*>')).Count
    
    $Content = $Content -replace '<tr[^>]*>', ''
    $openingTagsRemoved += ([regex]::Matches($originalContent, '<tr[^>]*>')).Count
    
    $Content = $Content -replace '<td[^>]*>', ''
    $openingTagsRemoved += ([regex]::Matches($originalContent, '<td[^>]*>')).Count
    
    # Remove table closing tags
    $Content = $Content -replace '</table>', ''
    $closingTagsRemoved += ([regex]::Matches($originalContent, '</table>')).Count
    
    $Content = $Content -replace '</tbody>', ''
    $closingTagsRemoved += ([regex]::Matches($originalContent, '</tbody>')).Count
    
    $Content = $Content -replace '</tr>', ''
    $closingTagsRemoved += ([regex]::Matches($originalContent, '</tr>')).Count
    
    $Content = $Content -replace '</td>', ''
    $closingTagsRemoved += ([regex]::Matches($originalContent, '</td>')).Count
    
    # Clean up excessive whitespace that might be left behind
    # Replace multiple consecutive blank lines with just two blank lines maximum
    $Content = $Content -replace '(\r?\n\s*){3,}', "`n`n"
    
    # Remove trailing whitespace from lines
    $Content = $Content -replace '[ \t]+(\r?\n)', '$1'
    
    return @{
        Content = $Content
        OpeningTagsRemoved = $openingTagsRemoved
        ClosingTagsRemoved = $closingTagsRemoved
        Modified = ($openingTagsRemoved -gt 0 -or $closingTagsRemoved -gt 0)
    }
}

# Main script execution
Write-Log "Starting table wrapper removal script"
Write-Log "Target path: $TargetPath"
Write-Log "WhatIf mode: $WhatIf"

# Find all markdown files
$markdownFiles = Get-ChildItem -Path $TargetPath -Filter "*.md" -Recurse
Write-Log "Found $($markdownFiles.Count) markdown files to process"

$filesProcessed = 0
$filesModified = 0
$totalOpeningTagsRemoved = 0
$totalClosingTagsRemoved = 0
$errors = 0

foreach ($file in $markdownFiles) {
    try {
        Write-Verbose "Processing: $($file.FullName)"
        
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        
        if ($null -eq $content) {
            $content = ""
        }
        
        # Process the content
        $result = Remove-TableWrappers -Content $content
        
        if ($result.Modified) {
            $totalOpeningTagsRemoved += $result.OpeningTagsRemoved
            $totalClosingTagsRemoved += $result.ClosingTagsRemoved
            
            Write-Verbose "Removed $($result.OpeningTagsRemoved) opening table tags and $($result.ClosingTagsRemoved) closing table tags"
            
            if ($WhatIf) {
                Write-Host "[WHATIF] WOULD MODIFY: $($file.FullName) (Remove $($result.OpeningTagsRemoved) opening and $($result.ClosingTagsRemoved) closing table tags)" -ForegroundColor Yellow
            } else {
                # Write the modified content back to file
                Set-Content -Path $file.FullName -Value $result.Content -Encoding UTF8 -NoNewline
                Write-Verbose "MODIFIED: $($file.FullName)"
            }
            
            $filesModified++
        }
        
        $filesProcessed++
        
    } catch {
        Write-Log "Error processing $($file.FullName): $($_.Exception.Message)" "ERROR"
        $errors++
    }
}

Write-Log "Script completed"
Write-Log "Files processed: $($filesProcessed)"
Write-Log "Files modified: $filesModified"
Write-Log "Total opening table tags removed: $totalOpeningTagsRemoved"
Write-Log "Total closing table tags removed: $totalClosingTagsRemoved"
Write-Log "Errors encountered: $errors"

if ($WhatIf) {
    Write-Log "This was a dry run. Use -WhatIf:`$false to actually make changes."
}