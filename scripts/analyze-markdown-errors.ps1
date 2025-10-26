# Analyze markdown lint errors and group by type
$reportFile = "markdownlint-results-after-fixes.txt"

# Read all errors
$errors = Get-Content $reportFile | Where-Object { $_ -match "MD\d{3}" }

# Group by error type
$grouped = $errors | ForEach-Object {
    if ($_ -match "(MD\d{3}):(.+)\((.+)\)") {
        [PSCustomObject]@{
            ErrorCode = $matches[1]
            Description = $matches[2].Trim()
            RuleName = $matches[3]
            FullLine = $_
        }
    }
} | Group-Object ErrorCode | Sort-Object Count -Descending

# Display summary
Write-Host "`n=== MARKDOWN LINT ERROR SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total Errors: $($errors.Count)" -ForegroundColor Yellow
Write-Host ""

foreach ($group in $grouped) {
    $example = $group.Group[0]
    Write-Host "[$($group.Name)] - $($group.Count) errors" -ForegroundColor Green
    Write-Host "  Description: $($example.Description)" -ForegroundColor Gray
    Write-Host "  Rule: $($example.RuleName)" -ForegroundColor Gray
    Write-Host ""
}

# Save detailed reports by error type
Write-Host "Creating individual error reports..." -ForegroundColor Cyan
foreach ($group in $grouped) {
    $filename = "errors-$($group.Name).txt"
    $group.Group.FullLine | Out-File $filename -Encoding UTF8
    Write-Host "  Created: $filename ($($group.Count) errors)" -ForegroundColor Gray
}

Write-Host "`nDone! Individual error reports created for each error type." -ForegroundColor Green
