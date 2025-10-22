# Script to replace middle dot bullets with Markdown bullets
# Processes the current active file only
# Usage: Pass the file path as a parameter

param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

if (-not (Test-Path $FilePath)) {
    Write-Host "Error: File not found: $FilePath" -ForegroundColor Red
    exit 1
}

# Read file with explicit UTF8 encoding
$content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)

# Replace middle dot (·) character (Unicode 183) with "- "
$middleDot = [char]183
$newContent = $content.Replace("$middleDot ", "- ")

# Count replacements
$replacements = ($content.ToCharArray() | Where-Object { [int]$_ -eq 183 }).Count

if ($content -eq $newContent) {
    Write-Host "No middle dot bullets found to replace" -ForegroundColor Yellow
} else {
    # Write back with UTF8 encoding (no BOM)
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($FilePath, $newContent, $utf8NoBom)
    
    Write-Host "Success! Replaced $replacements middle dot bullets with Markdown bullets" -ForegroundColor Green
}
