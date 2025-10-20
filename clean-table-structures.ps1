# Script to remove unnecessary table structures and convert content to proper Markdown

$inputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_clean_tables.md"
$outputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_markdown_clean.md"

# Read the input file
$content = Get-Content $inputFile -Raw

Write-Host "Cleaning up table structures and converting to proper Markdown..."

# Count tables before processing
$allTableMatches = [regex]::Matches($content, '<table>.*?</table>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$totalTables = $allTableMatches.Count
Write-Host "Found $totalTables table structures to process..."

# Pattern 1: Tables containing only paragraph content (most common case)
# Extract content from <p> tags within tables and convert to clean markdown
$tableWithParagraphPattern = '(?s)<table>\s*<tbody>\s*<tr>\s*<td>\s*(<p>.*?</p>(?:\s*<p>.*?</p>)*)\s*</td>\s*</tr>\s*</tbody>\s*</table>'

$content = [regex]::Replace($content, $tableWithParagraphPattern, {
    param($match)
    $paragraphContent = $match.Groups[1].Value
    
    # Extract text from each <p> tag and clean it up
    $cleanedParagraphs = [regex]::Replace($paragraphContent, '<p>(.*?)</p>', {
        param($pMatch)
        $text = $pMatch.Groups[1].Value.Trim()
        
        # Convert TIP: to proper markdown admonition format
        if ($text -match '^TIP:\s*(.*)') {
            return "!!! tip`n    " + $matches[1]
        }
        # Convert NOTE: to proper markdown admonition format  
        elseif ($text -match '^NOTE:\s*(.*)') {
            return "!!! note`n    " + $matches[1]
        }
        # For regular content, just return the text
        else {
            return $text
        }
    }, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    # Split multiple paragraphs and rejoin with proper spacing
    $paragraphs = $cleanedParagraphs -split "`n" | Where-Object { $_.Trim() -ne "" }
    return ($paragraphs -join "`n`n")
})

# Count how many were processed
$remainingTableMatches = [regex]::Matches($content, '<table>.*?</table>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
$remainingTables = $remainingTableMatches.Count
$processedTables = $totalTables - $remainingTables

Write-Host "Processed $processedTables table structures"
if ($remainingTables -gt 0) {
    Write-Host "Remaining $remainingTables tables (may be complex or empty)"
}

# Clean up any remaining simple table structures that might be empty or contain only whitespace
$emptyTablePattern = '(?s)<table>\s*<tbody>\s*<tr>\s*<td>\s*</td>\s*</tr>\s*</tbody>\s*</table>'
$emptyTableCount = [regex]::Matches($content, $emptyTablePattern).Count
if ($emptyTableCount -gt 0) {
    $content = [regex]::Replace($content, $emptyTablePattern, '')
    Write-Host "Removed $emptyTableCount empty table structures"
}

# Clean up excessive whitespace
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

Write-Host "`nConversion complete! Document now uses proper Markdown formatting."

# Show a sample of what was converted
Write-Host "`nSample of converted content:"
$sampleMatch = [regex]::Match($content, '!!! (tip|note).*?(?=\n\n|\n[A-Z]|\n\*\*|$)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
if ($sampleMatch.Success) {
    Write-Host $sampleMatch.Value
} else {
    Write-Host "No tip/note conversions found in sample."
}