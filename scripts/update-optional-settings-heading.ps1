# Update "Optional Settings" to "## Optional Display Settings" in exercise set files

$exerciseSetsPath = ".\docs\exercise-sets"
$files = Get-ChildItem -Path $exerciseSetsPath -Filter "*.md" -Recurse
$modifiedCount = 0

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Replace "Optional Settings" with "## Optional Display Settings"
    # This will match it whether it's standalone or followed by newlines
    $newContent = $content -replace '(?m)^Optional Settings$', '## Optional Display Settings'
    
    # Only write if content changed
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "Fixed: $($file.Name)"
        $modifiedCount++
    }
}

Write-Host "`nTotal files modified: $modifiedCount"
