# Script to remove empty table structures from the document

$inputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_final.md"
$outputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_clean_tables.md"

# Read the input file
$content = Get-Content $inputFile -Raw

Write-Host "Removing empty table structures..."

# Pattern to match empty table structures
$emptyTablePattern = @'
<table>
<tbody>
<tr>
</tr>
</tbody>
</table>
'@

# Count empty tables before removal
$emptyTableMatches = [regex]::Matches($content, [regex]::Escape($emptyTablePattern))
$emptyTableCount = $emptyTableMatches.Count

Write-Host "Found $emptyTableCount empty table structures to remove..."

# Remove empty tables
if ($emptyTableCount -gt 0) {
    $content = $content -replace [regex]::Escape($emptyTablePattern), ""
    Write-Host "Removed $emptyTableCount empty table structures"
} else {
    Write-Host "No empty table structures found"
}

# Also remove any standalone empty table tags that might exist
$standaloneTablePattern = '<table>\s*</table>'
$standaloneMatches = [regex]::Matches($content, $standaloneTablePattern)
$standaloneCount = $standaloneMatches.Count

if ($standaloneCount -gt 0) {
    $content = [regex]::Replace($content, $standaloneTablePattern, "")
    Write-Host "Removed $standaloneCount standalone empty table tags"
}

# Clean up any excessive whitespace left behind
$content = $content -replace "`r`n`r`n`r`n`r`n", "`r`n`r`n"
$content = $content -replace "`r`n`r`n`r`n", "`r`n`r`n"

# Save the cleaned content
$content | Out-File -FilePath $outputFile -Encoding UTF8

Write-Host "Cleaned document saved to: $outputFile"

# Show file size comparison
$originalSize = (Get-Item $inputFile).Length
$newSize = (Get-Item $outputFile).Length
$reduction = $originalSize - $newSize
$percentReduction = [math]::Round(($reduction / $originalSize) * 100, 2)

Write-Host "`nFile size comparison:"
Write-Host "Original: $([math]::Round($originalSize/1MB, 2)) MB"
Write-Host "New: $([math]::Round($newSize/1MB, 2)) MB"
Write-Host "Reduction: $([math]::Round($reduction/1KB, 1)) KB ($percentReduction%)"

Write-Host "`nProcess complete! Document is now ready for splitting into individual files."