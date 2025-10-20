# Script to extract shared Options sections and clean up the document

param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputFile,
    
    [Parameter(Mandatory=$true)]
    [string]$OptionsFolder
)

# Read the entire document
$content = Get-Content $InputFile -Raw -Encoding UTF8

Write-Host "Original file size: $($content.Length) characters"

# Define the shared sections to extract
$sharedSections = @(
    'Exercise Set Display Options',
    'Title Display Options', 
    'Instructions Display Options',
    'Numbering Display Options',
    'Answer Bank Display Options'
)

# Create options folder if it doesn't exist
if (-not (Test-Path $OptionsFolder)) {
    New-Item -ItemType Directory -Path $OptionsFolder -Force
    Write-Host "Created options folder: $OptionsFolder"
}

# Extract each shared section (find the first good copy)
foreach ($sectionName in $sharedSections) {
    Write-Host "Extracting: $sectionName"
    
    # Find the section using regex
    $pattern = "(?s)\*\*$sectionName\*\*.*?(?=\*\*[^*]+\*\*|\z)"
    $matches = [regex]::Matches($content, $pattern)
    
    if ($matches.Count -gt 0) {
        # Get the first match (usually the cleanest)
        $sectionContent = $matches[0].Value
        
        # Clean up the section
        $sectionContent = $sectionContent.Trim()
        
        # Create filename
        $filename = $sectionName.Replace(' ', '-').ToLower() + '.md'
        $filepath = Join-Path $OptionsFolder $filename
        
        # Add heading and save
        $fileContent = "# $sectionName`n`n$sectionContent"
        $fileContent | Out-File -FilePath $filepath -Encoding UTF8
        
        Write-Host "  Saved: $filename ($($sectionContent.Length) chars)"
    } else {
        Write-Host "  WARNING: Could not find section: $sectionName"
    }
}

# Now remove all instances of these sections from the main document
Write-Host "`nRemoving shared sections from main document..."

foreach ($sectionName in $sharedSections) {
    # Remove all instances of this section
    $pattern = "(?s)\*\*$sectionName\*\*.*?(?=\*\*[^*]+\*\*|\z)"
    $beforeCount = [regex]::Matches($content, $pattern).Count
    $content = [regex]::Replace($content, $pattern, "")
    $afterCount = [regex]::Matches($content, $pattern).Count
    
    Write-Host "  Removed $($beforeCount - $afterCount) instances of: $sectionName"
}

# Remove empty tables that appear after section headers
$content = [regex]::Replace($content, "(?s)<table>\s*<tbody>\s*<tr>\s*</tr>\s*</tbody>\s*</table>", "")

# Clean up excessive whitespace
$content = [regex]::Replace($content, "\n{3,}", "`n`n")

# Save the cleaned document
$content | Out-File -FilePath $OutputFile -Encoding UTF8

Write-Host "`nCleaned file size: $($content.Length) characters"
Write-Host "Reduction: $(($content.Length / (Get-Content $InputFile -Raw).Length * 100).ToString('F1'))% of original size"
Write-Host "`nFiles created:"
Write-Host "  Main document: $OutputFile"
Write-Host "  Options folder: $OptionsFolder"

Get-ChildItem $OptionsFolder | ForEach-Object {
    Write-Host "    $($_.Name)"
}