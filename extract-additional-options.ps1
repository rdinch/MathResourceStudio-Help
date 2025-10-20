# Enhanced script to extract additional shared sections from activities
# and add them to the Exercise Set Display Options file

$inputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual.md"
$outputFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Math8_manual_final.md"
$exerciseOptionsFile = "c:\Users\Robert\Dropbox\Documents\Visual Studio 2022\Projects\MRS8\WordDoc\Options\exercise-set-display-options.md"

# Read the input file
$content = Get-Content $inputFile -Raw

Write-Host "Processing additional shared sections..."

# Define the additional sections to extract
$sections = @{
    "Answer Lines" = @"
**Answer Lines**

For many exercise sets answer lines are shown by default. These lines can be customized or hidden depending on the exercise set.

Note: If the answer lines are hidden, the answer space remains. You can also adjust "Row Spacing" to make the space between exercises larger for students to show their calculations.

Visible

You can check or uncheck the "Visible" box to show or hide the answer lines for each exercise set.

Change the color

1\. In the options panel, find and select "Color."

2\. Click the three dots \(ellipsis\) in the color box to open the color picker.

3\. Choose the color you like.

4\. Click "OK" to save your choice and apply the new color.

Change the line width

1\. Click on "Width" in the options panel.

2\. Type a number between 0 and 10, or use the up/down arrows to adjust the width of the line.

Style

Choose one of these types of answer lines:

· Solid

· Dotted

· Dashed
"@

    "Add a Border" = @"
**Add a Border**

To show a border around an object, click the Border option in the options panel. Then, check the boxes for the sides you want to see the border on. Uncheck the boxes for the sides you don't want a border on.

Change the color

1\. In the options panel, find and select "Color."

2\. Click the three dots \(ellipsis\) in the color box to open the color picker.

3\. Choose the color you like.

4\. Click "OK" to save your choice and apply the new color.

Change the line width

1\. Click on "Width" in the options panel.

2\. Type a number between 0 and 10, or use the up/down arrows to adjust the width of the line.

Round the corners

Click in the check box for "Rounded" in the options panel. Uncheck the box to set the border back to square corners

Adjust the padding

Sets the padding \(extra white space\) around the element in 100ths of an inch \(25 = 1/4 inch, 40 = 1cm\).

1\. Select the Padding option in the options pane.

2\. Select a side \(left, right, top, or bottom\) to change the value for that side.

3\. Type a new value in the input field or use the up and down arrows to increase or decrease the value. Valid range: 0 to 100.
"@

    "Background Grid" = @"
**Background Grid**

Try adding a background grid to your exercise set to help students line up their written work in the space provided.

TIP: You provide a large calculating space for questions like multi-digit division or multiplication by increasing row spacing and hiding the answer lines. The background grid helps younger learners organize their work.

Visible

Turn the "Visible" option on or off to show or hide the background grid for the exercise set.

Change the color

1\. In the options panel, find and select "Color."

2\. Click the three dots \(ellipsis\) in the color box to open the color picker.

3\. Choose the color you like.

4\. Click "OK" to save your choice and apply the new color.

Cell Width and Cell Height

You can change the size of grid cells by adjusting their width and height. The measurements are in hundredths of an inch. For example:

· 25 = 1/4 inch

· 40 = about 1 centimeter

1\. Click on the input box for "Cell Width" or "Cell Height" in the options panel.

2\. Type in a new number, or use the up/down arrows to adjust the value. The number range is from 5 to 50.

Style

Choose one of these types of background lines:

· Solid

· Dotted

<table>
<tbody>
<tr>
<td><p>TIP: Use monospaced fonts for better spacing. Good examples are: Courier, Courier New, Lucida Console, Monaco, and Consolas.</p>
<p>· Dashed</p></td>
</tr>
</tbody>
</table>
"@
}

# Count removals for tracking
$totalRemovals = 0

# Remove each section from the content and count
foreach ($sectionName in $sections.Keys) {
    $sectionContent = $sections[$sectionName]
    
    # Create regex pattern - escape special regex characters
    $escapedSection = [regex]::Escape($sectionContent)
    
    # Count matches before removal
    $matches = [regex]::Matches($content, $escapedSection)
    $removeCount = $matches.Count
    
    if ($removeCount -gt 0) {
        Write-Host "Removing $removeCount instances of '$sectionName' section..."
        $content = $content -replace $escapedSection, ""
        $totalRemovals += $removeCount
    } else {
        Write-Host "No instances of '$sectionName' found to remove."
    }
}

# Save the cleaned content
$content | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "Cleaned document saved to: $outputFile"
Write-Host "Total sections removed: $totalRemovals"

# Now append the additional sections to the Exercise Set Display Options file
Write-Host "`nAppending additional sections to Exercise Set Display Options file..."

$additionalContent = @"

## Additional Display Options

$($sections["Answer Lines"])

$($sections["Add a Border"])

$($sections["Background Grid"])
"@

# Append to the exercise options file
Add-Content -Path $exerciseOptionsFile -Value $additionalContent -Encoding UTF8

Write-Host "Additional sections added to: $exerciseOptionsFile"
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