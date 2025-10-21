# Script to remove repetitive options sections from all activity files
# Removes everything from "**Exercise Set Display Options**" to end of file

$activityFolder = "docs\activities"
$files = Get-ChildItem "$activityFolder\*.md"

Write-Host "Cleaning $($files.Count) activity files..." -ForegroundColor Green

$totalSaved = 0
$filesProcessed = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $originalSize = $content.Length
    
    # Find the start of the options sections
    $optionsStart = $content.IndexOf("**Exercise Set Display Options**")
    
    if ($optionsStart -gt 0) {
        # Keep everything before the options sections
        $cleanedContent = $content.Substring(0, $optionsStart).TrimEnd()
        
        # Save the cleaned file
        $cleanedContent | Set-Content $file.FullName -Encoding UTF8
        
        $newSize = $cleanedContent.Length
        $saved = $originalSize - $newSize
        $totalSaved += $saved
        $filesProcessed++
        
        Write-Host "  $($file.Name): removed $saved characters" -ForegroundColor Cyan
    } else {
        Write-Host "  $($file.Name): no options section found" -ForegroundColor Yellow
    }
}

Write-Host "`nCleanup completed!" -ForegroundColor Green
Write-Host "Files processed: $filesProcessed" -ForegroundColor Yellow
Write-Host "Total characters removed: $totalSaved" -ForegroundColor Yellow
Write-Host "Average reduction per file: $(if($filesProcessed -gt 0) { [int]($totalSaved / $filesProcessed) } else { 0 }) characters" -ForegroundColor Yellow