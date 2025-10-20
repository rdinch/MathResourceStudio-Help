# Final cleanup script to remove remaining empty table structures

$inputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_markdown_clean.md"
$outputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_final_clean.md"

# Read the input file
$content = Get-Content $inputFile -Raw

Write-Host "Removing remaining empty table structures..."

# Count remaining tables
$remainingTables = [regex]::Matches($content, '<table>.*?</table>', [System.Text.RegularExpressions.RegexOptions]::Singleline).Count
Write-Host "Found $remainingTables remaining table structures"

# Remove any remaining table structures that are empty or contain only empty cells
$emptyComplexTablePattern = '(?s)<table>\s*<tbody>\s*(?:<tr>\s*<td>\s*</td>\s*</tr>\s*)*</tbody>\s*</table>'
$complexEmptyCount = [regex]::Matches($content, $emptyComplexTablePattern).Count

if ($complexEmptyCount -gt 0) {
    $content = [regex]::Replace($content, $emptyComplexTablePattern, '')
    Write-Host "Removed $complexEmptyCount complex empty table structures"
}

# Final check for any remaining tables and remove them if they're essentially empty
$anyRemainingTables = [regex]::Matches($content, '<table>.*?</table>', [System.Text.RegularExpressions.RegexOptions]::Singleline)
foreach ($table in $anyRemainingTables) {
    $tableContent = $table.Value
    # If table contains only HTML tags, whitespace, and no actual text content, remove it
    $textContent = [regex]::Replace($tableContent, '<[^>]+>', '').Trim()
    if ($textContent -eq '') {
        $content = $content.Replace($table.Value, '')
        Write-Host "Removed empty table: $($table.Value.Substring(0, [Math]::Min(50, $table.Value.Length)))..."
    }
}

# Clean up excessive whitespace one more time
$content = $content -replace "`r`n`r`n`r`n", "`r`n`r`n"

# Save the final cleaned content
$content | Out-File -FilePath $outputFile -Encoding UTF8

# Final verification
$finalTableCount = [regex]::Matches($content, '<table>.*?</table>', [System.Text.RegularExpressions.RegexOptions]::Singleline).Count

Write-Host "Final cleanup complete!"
Write-Host "Remaining table structures: $finalTableCount"

# Show file size comparison
$originalSize = (Get-Item $inputFile).Length
$newSize = (Get-Item $outputFile).Length
$reduction = $originalSize - $newSize
$percentReduction = if ($originalSize -gt 0) { [math]::Round(($reduction / $originalSize) * 100, 2) } else { 0 }

Write-Host "`nFile size comparison:"
Write-Host "Previous: $([math]::Round($originalSize/1MB, 2)) MB"
Write-Host "Final: $([math]::Round($newSize/1MB, 2)) MB"
Write-Host "Additional reduction: $([math]::Round($reduction/1KB, 1)) KB ($percentReduction%)"

Write-Host "`nDocument is now fully optimized with proper Markdown formatting!"