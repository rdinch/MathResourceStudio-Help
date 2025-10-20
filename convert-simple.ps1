# Simple CHM to Markdown Conversion Script
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
    
    # Basic cleanup for Help and Manual content
    $content = $content -replace '(?s)<script.*?</script>', ''
    $content = $content -replace '(?s)<style.*?</style>', ''
    $content = $content -replace '(?s)<div id="idheader">.*?</div>', ''
    $content = $content -replace '(?s)<!--ZOOMSTOP-->.*?<!--ZOOMRESTART-->', ''
    
    # Remove complex table formatting
    $content = $content -replace '<table[^>]*style="border:none;border-spacing:0px[^"]*"[^>]*>', '<div>'
    $content = $content -replace '</table>', '</div>'
    $content = $content -replace '<tr[^>]*>', ''
    $content = $content -replace '</tr>', ''
    $content = $content -replace '<td[^>]*>', ''
    $content = $content -replace '</td>', ' '
    
    # Remove attributes
    $content = $content -replace '\sclass="[^"]*"', ''
    $content = $content -replace '\sstyle="[^"]*"', ''
    $content = $content -replace '\sid="[^"]*"', ''
    
    # Clean up spans
    $content = $content -replace '<span[^>]*>', ''
    $content = $content -replace '</span>', ''
    
    # Focus on main content
    if ($content -match '(?s)<div id="idcontent">(.*?)</div>\s*</body>') {
        $content = "<html><body>" + $matches[1] + "</body></html>"
    }
    
    # Convert bullet points
    $content = $content -replace '&#8226;', '*'
    
    # Create temporary cleaned HTML file
    $tempFile = [System.IO.Path]::GetTempFileName() + ".html"
    $content | Out-File -FilePath $tempFile -Encoding UTF8
    
    # Convert with Pandoc
    $outputFile = Join-Path $OutputFolder ($file.BaseName + ".md")
    
    & pandoc $tempFile `
        --from html `
        --to markdown_strict `
        --wrap=none `
        --strip-comments `
        --syntax-highlighting=none `
        --output $outputFile
    
    # Clean up temp file
    Remove-Item $tempFile
    
    # Simple post-processing
    if (Test-Path $outputFile) {
        $mdContent = Get-Content $outputFile -Raw -Encoding UTF8
        
        # Save cleaned content
        $mdContent | Out-File -FilePath $outputFile -Encoding UTF8
        
        Write-Host "[SUCCESS] Converted: $($file.Name)"
    } else {
        Write-Host "[FAILED] Failed to convert: $($file.Name)"
    }
}

Write-Host "Conversion complete!"