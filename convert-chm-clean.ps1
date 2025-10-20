# Improved CHM to Markdown Conversion Script
# This script converts HTML files extracted from CHM to clean Markdown

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFolder,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputFolder
)

# Create output folder if it doesn't exist
if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force
}

# Get all HTML files
$htmlFiles = Get-ChildItem -Path $InputFolder -Filter "*.htm*" -Recurse

Write-Host "Found $($htmlFiles.Count) HTML files to convert"

foreach ($file in $htmlFiles) {
    Write-Host "Processing: $($file.Name)"
    
    # Read the HTML content
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # More aggressive cleaning for Help and Manual content
    
    # Remove all JavaScript
    $content = $content -replace '(?s)<script.*?</script>', ''
    
    # Remove all CSS styles
    $content = $content -replace '(?s)<style.*?</style>', ''
    
    # Remove navigation and header elements
    $content = $content -replace '(?s)<div id="idheader">.*?</div>', ''
    $content = $content -replace '(?s)<div id="printheader">.*?</div>', ''
    $content = $content -replace '(?s)<!--ZOOMSTOP-->.*?<!--ZOOMRESTART-->', ''
    
    # Remove all complex table formatting (Help & Manual uses tables for layout)
    $content = $content -replace '<table[^>]*style="border:none;border-spacing:0px[^"]*"[^>]*>', '<div>'
    $content = $content -replace '</table>', '</div>'
    $content = $content -replace '<tr[^>]*>', ''
    $content = $content -replace '</tr>', ''
    $content = $content -replace '<td[^>]*>', ''
    $content = $content -replace '</td>', ' '
    
    # Remove toggle buttons and JavaScript calls
    $content = $content -replace 'javascript:HMToggle[^"]*', '#'
    $content = $content -replace '<img[^>]*hmtoggle[^>]*>', ''
    
    # Remove all class and style attributes
    $content = $content -replace '\sclass="[^"]*"', ''
    $content = $content -replace '\sstyle="[^"]*"', ''
    $content = $content -replace '\sid="[^"]*"', ''
    
    # Clean up spans with formatting classes
    $content = $content -replace '<span[^>]*>', ''
    $content = $content -replace '</span>', ''
    
    # Focus on the main content area
    if ($content -match '(?s)<div id="idcontent">(.*?)</div>\s*</body>') {
        $content = "<html><body>" + $matches[1] + "</body></html>"
    } elseif ($content -match '(?s)<div id="innerdiv">(.*?)</div>') {
        $content = "<html><body>" + $matches[1] + "</body></html>"
    }
    
    # Convert bullet points to proper list format
    $content = $content -replace '&#8226;', '*'
    
    # Create temporary cleaned HTML file
    $tempFile = [System.IO.Path]::GetTempFileName() + ".html"
    $content | Out-File -FilePath $tempFile -Encoding UTF8
    
    # Convert with Pandoc using more aggressive cleaning options
    $outputFile = Join-Path $OutputFolder ($file.BaseName + ".md")
    
    # Pandoc command optimized for cleaner output
    & pandoc $tempFile `
        --from html `
        --to markdown_strict `
        --wrap=none `
        --strip-comments `
        --syntax-highlighting=none `
        --output $outputFile
    
    # Clean up temp file
    Remove-Item $tempFile
    
    # Post-process the Markdown file for maximum cleanliness
    if (Test-Path $outputFile) {
        $mdContent = Get-Content $outputFile -Raw -Encoding UTF8
        
        # Remove Pandoc divs and complex formatting
        $mdContent = $mdContent -replace ':::[^:]*?:::', ''
        $mdContent = $mdContent -replace '\{[^}]*\}', ''
        $mdContent = $mdContent -replace '\[[^\]]*\]\{[^}]*\}', ''
        
        # Simple but effective cleanup
        # Remove encoding artifacts
        $mdContent = $mdContent -replace [char]0x00A0, ' '
        $mdContent = $mdContent -replace 'Â', ''
        
        # Fix escaped characters
        $mdContent = $mdContent -replace '\\(\*)', '*'
        $mdContent = $mdContent -replace '\\(\.)', '.'
        
        # Fix lists
        $mdContent = $mdContent -replace '(?m)^\s*\\?\*\s*', '- '
        $mdContent = $mdContent -replace '(?m)^(\d+)\\\.\s*', '$1. '
        
        # Clean up excessive line breaks and spacing
        $mdContent = $mdContent -replace '\n{3,}', "`n`n"
        $mdContent = $mdContent -replace '(?m)^\s*$\n', ''
        
        # Fix table artifacts
        $mdContent = $mdContent -replace '-{3,}', ''
        $mdContent = $mdContent -replace '\|.*?\|', ''
        
        # Clean up headings - remove attributes and fix formatting
        $mdContent = $mdContent -replace '(?m)^(.+)[\s]*\{[^}]*\}', '$1'
        $mdContent = $mdContent -replace '(?m)^### (.+) ###', '### $1'
        
        # Remove navigation breadcrumbs and metadata
        $mdContent = $mdContent -replace '(?m)^.*?Navigation:.*?\n', ''
        $mdContent = $mdContent -replace '(?m)^.*?Exercise sets.*?\n', ''
        $mdContent = $mdContent -replace '(?m)^.*?>> \n', ''
        
        # Fix heading hierarchy
        $mdContent = $mdContent -replace '^####', '###'
        $mdContent = $mdContent -replace '^#####', '####'
        
        # Clean up whitespace issues
        $mdContent = $mdContent -replace ' +', ' '
        $mdContent = $mdContent -replace ' \n', "`n"
        $mdContent = $mdContent -replace '\n ', "`n"
        
        # Remove empty lines that just contain whitespace
        $mdContent = $mdContent -replace '(?m)^[ \t]+$', ''
        
        # Fix common CHM artifacts
        $mdContent = $mdContent -replace 'NOTE:', '**NOTE:**'
        $mdContent = $mdContent -replace 'TIP:', '**TIP:**'
        $mdContent = $mdContent -replace 'WARNING:', '**WARNING:**'
        
        # Final cleanup
        $mdContent = $mdContent.Trim()
        
        # Ensure proper line endings
        $mdContent = $mdContent -replace '\r\n', "`n"
        $mdContent = $mdContent -replace '\r', "`n"
        
        # Save cleaned markdown
        try {
            [System.IO.File]::WriteAllText($outputFile, $mdContent, [System.Text.Encoding]::UTF8)
            Write-Host "[SUCCESS] Converted: $($file.Name) -> $($file.BaseName).md"
        } catch {
            Write-Host "[ERROR] Failed to save: $($file.Name) - $($_.Exception.Message)"
        }
    } else {
        Write-Host "[FAILED] Failed to convert: $($file.Name)"
    }
}

Write-Host "`nConversion complete! Check the output folder: $OutputFolder"
Write-Host "`nNext steps:"
Write-Host "1. Review the converted files"
Write-Host "2. Organize them into your MkDocs structure"
Write-Host "3. Update internal links"
Write-Host "4. Add to mkdocs.yml navigation"