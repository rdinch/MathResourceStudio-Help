# Flexible script to extract additional shared sections from activities
# This version uses header patterns to identify section boundaries

$inputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual.md"
$outputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_final.md"
$exerciseOptionsFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Options\exercise-set-display-options.md"

# Read the input file
$content = Get-Content $inputFile -Raw

Write-Host "Processing additional shared sections with flexible pattern matching..."

# Function to extract section content between two headers
function Extract-Section {
    param(
        [string]$Content,
        [string]$StartPattern,
        [string]$EndPattern
    )
    
    $regex = "(?s)(\*\*$StartPattern\*\*.*?)(\*\*$EndPattern\*\*|\*\*<u>|$)"
    $matches = [regex]::Matches($Content, $regex)
    
    if ($matches.Count -gt 0) {
        # Return the first match without the end pattern
        $sectionContent = $matches[0].Groups[1].Value.Trim()
        return $sectionContent
    }
    return $null
}

# Extract the first occurrence of each section to add to options file
$answerLinesSection = Extract-Section -Content $content -StartPattern "Answer Lines" -EndPattern "Add a Border"
$borderSection = Extract-Section -Content $content -StartPattern "Add a Border" -EndPattern "Background Grid"
$backgroundGridSection = Extract-Section -Content $content -StartPattern "Background Grid" -EndPattern "Title Display Options"

Write-Host "Extracted sections:"
if ($answerLinesSection) { Write-Host "- Answer Lines section found" }
if ($borderSection) { Write-Host "- Add a Border section found" }
if ($backgroundGridSection) { Write-Host "- Background Grid section found" }

# Count and remove all instances of these sections
$totalRemovals = 0

# Remove Answer Lines sections
$answerLinesPattern = '(?s)\*\*Answer Lines\*\*.*?(?=\*\*Add a Border\*\*|\*\*Background Grid\*\*|\*\*Title Display Options\*\*|\*\*<u>|$)'
$answerLinesMatches = [regex]::Matches($content, $answerLinesPattern)
$answerLinesCount = $answerLinesMatches.Count
if ($answerLinesCount -gt 0) {
    Write-Host "Removing $answerLinesCount instances of 'Answer Lines' sections..."
    $content = [regex]::Replace($content, $answerLinesPattern, "")
    $totalRemovals += $answerLinesCount
}

# Remove Add a Border sections  
$borderPattern = '(?s)\*\*Add a Border\*\*.*?(?=\*\*Background Grid\*\*|\*\*Title Display Options\*\*|\*\*<u>|$)'
$borderMatches = [regex]::Matches($content, $borderPattern)
$borderCount = $borderMatches.Count
if ($borderCount -gt 0) {
    Write-Host "Removing $borderCount instances of 'Add a Border' sections..."
    $content = [regex]::Replace($content, $borderPattern, "")
    $totalRemovals += $borderCount
}

# Remove Background Grid sections
$gridPattern = '(?s)\*\*Background Grid\*\*.*?(?=\*\*Title Display Options\*\*|\*\*<u>|$)'
$gridMatches = [regex]::Matches($content, $gridPattern)
$gridCount = $gridMatches.Count
if ($gridCount -gt 0) {
    Write-Host "Removing $gridCount instances of 'Background Grid' sections..."
    $content = [regex]::Replace($content, $gridPattern, "")
    $totalRemovals += $gridCount
}

# Clean up any double line breaks left behind
$content = $content -replace "`r`n`r`n`r`n", "`r`n`r`n"

# Save the cleaned content
$content | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "Cleaned document saved to: $outputFile"
Write-Host "Total sections removed: $totalRemovals"

# Append the additional sections to the Exercise Set Display Options file
if ($answerLinesSection -or $borderSection -or $backgroundGridSection) {
    Write-Host "`nAppending additional sections to Exercise Set Display Options file..."
    
    $additionalContent = "`r`n`r`n## Additional Display Options`r`n`r`n"
    
    if ($answerLinesSection) {
        $additionalContent += $answerLinesSection + "`r`n`r`n"
    }
    if ($borderSection) {
        $additionalContent += $borderSection + "`r`n`r`n"
    }
    if ($backgroundGridSection) {
        $additionalContent += $backgroundGridSection + "`r`n`r`n"
    }
    
    # Append to the exercise options file
    Add-Content -Path $exerciseOptionsFile -Value $additionalContent -Encoding UTF8
    Write-Host "Additional sections added to: $exerciseOptionsFile"
}

Write-Host "`nProcess complete!"

# Show file size comparison
$originalSize = (Get-Item $inputFile).Length
$newSize = (Get-Item $outputFile).Length
$reduction = $originalSize - $newSize
$percentReduction = [math]::Round(($reduction / $originalSize) * 100, 1)

Write-Host "`nFile size comparison:"
Write-Host "Original: $([math]::Round($originalSize/1MB, 2)) MB"
Write-Host "New: $([math]::Round($newSize/1MB, 2)) MB"
Write-Host "Reduction: $([math]::Round($reduction/1MB, 2)) MB ($percentReduction%)"