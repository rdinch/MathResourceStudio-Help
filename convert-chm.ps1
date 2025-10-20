# CHM to Markdown Conversion Script
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
    
    # Clean up Help and Manual specific elements
    # Remove JavaScript
    $content = $content -replace '(?s)<script.*?</script>', ''
    
    # Remove CSS styles
    $content = $content -replace '(?s)<style.*?</style>', ''
    
    # Remove navigation elements
    $content = $content -replace '(?s)<div id="idheader">.*?</div>', ''
    $content = $content -replace '(?s)<!--ZOOMSTOP-->.*?<!--ZOOMRESTART-->', ''
    
    # Remove toggle buttons and JavaScript calls
    $content = $content -replace 'javascript:HMToggle[^"]*', '#'
    $content = $content -replace '<img[^>]*hmtoggle[^>]*>', ''
    
    # Remove CHM-specific navigation
    $content = $content -replace '(?s)<p class="p_List">.*?Navigation:.*?</p>', ''
    
    # Focus on the main content area
    if ($content -match '(?s)<div id="idcontent">(.*?)</div>\s*</body>') {
        $content = "<html><body>" + $matches[1] + "</body></html>"
    }
    
    # Create temporary cleaned HTML file
    $tempFile = [System.IO.Path]::GetTempFileName() + ".html"
    $content | Out-File -FilePath $tempFile -Encoding UTF8
    
    # Convert with Pandoc
    $outputFile = Join-Path $OutputFolder ($file.BaseName + ".md")
    
    # Pandoc command with options optimized for Help and Manual content
    & pandoc $tempFile `
        --from html `
        --to markdown `
        --wrap=none `
        --markdown-headings=atx `
        --strip-comments `
        --output $outputFile
    
    # Clean up temp file
    Remove-Item $tempFile
    
    # Post-process the Markdown file
    if (Test-Path $outputFile) {
        $mdContent = Get-Content $outputFile -Raw -Encoding UTF8
        
        # Clean up common issues
        $mdContent = $mdContent -replace '\n{3,}', "`n`n"  # Remove excessive line breaks
        $mdContent = $mdContent -replace '(?m)^\s*$\n', ''  # Remove empty lines with spaces
        $mdContent = $mdContent -replace '\*\*Navigation:\*\*.*?\n', ''  # Remove navigation breadcrumbs
        
        # Fix heading hierarchy (Help and Manual often has odd heading levels)
        $mdContent = $mdContent -replace '^####', '###'  # Convert h4 to h3
        $mdContent = $mdContent -replace '^#####', '####'  # Convert h5 to h4
        
        # Save cleaned markdown
        $mdContent | Out-File -FilePath $outputFile -Encoding UTF8 -NoNewline
        
        Write-Host "[SUCCESS] Converted: $($file.Name) -> $($file.BaseName).md"
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