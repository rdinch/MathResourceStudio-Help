# Script to move all activity files into their respective category folders
# Based on the desired folder structure

# Define the base activities path
$activitiesPath = Join-Path $PSScriptRoot "..\docs\activities"

Write-Host "Moving all activity files into category folders" -ForegroundColor Cyan
Write-Host "Base path: $activitiesPath" -ForegroundColor Gray
Write-Host ""

# Define the file mappings: Category -> Array of files
$fileMapping = @{
    "Algebra" = @(
        "equations---defined-variable.md",
        "equations---single-variable-(one-side).md",
        "inequalities.md",
        "number-problems.md",
        "pre-algebra-equations-one-side.md",
        "pre-algebra-equations-two-sides.md",
        "simplifying-expressions.md"
    )
    "Basic Number Operations" = @(
        "basic-addition.md",
        "basic-addition---doubles.md",
        "basic-addition-fixed-addend.md",
        "basic-addition-and-regrouping.md",
        "basic-division.md",
        "basic-multiplication.md",
        "basic-multiplication-fixed-factor.md",
        "basic-subtraction.md",
        "basic-subtraction-and-regrouping.md",
        "fact-families.md",
        "input-output.md",
        "make-sum.md",
        "match-ups.md",
        "mixed-basic-operations.md",
        "multiple-operations-addition-subtraction.md",
        "pictorial-addition.md",
        "quick-facts.md",
        "word-problems---addition.md",
        "word-problems---division.md",
        "word-problems---multiplication.md",
        "word-problems---subtraction.md"
    )
    "Consumer Math" = @(
        "compound-interest.md",
        "counting-money.md",
        "money-in-words.md",
        "shopping-problems.md",
        "shopping-problems-ii.md",
        "simple-interest.md",
        "wages.md"
    )
    "Coordinates" = @(
        "cartesian-coordinates---four-quadrants.md",
        "cartesian-coordinates---single-quadrant.md",
        "plot-lines.md"
    )
    "Custom" = @(
        "custom-questions.md",
        "custom-word-problems.md"
    )
    "Fractions" = @(
        "comparing-fractions.md",
        "division-with-whole-numbers.md",
        "equivalent-fractions.md",
        "fraction-identification---grids.md",
        "fraction-identification---rectangles.md",
        "fractions-addition.md",
        "fractions-and-decimals.md",
        "fractions-division.md",
        "fractions-multiplication.md",
        "fractions-subtraction.md",
        "fractions-multiple-operations.md",
        "mixed-numbers-and-improper-fractions.md",
        "mixed-operations-with-fractions.md",
        "multiplication-with-whole-numbers.md",
        "order-fractional-values.md",
        "simplifying-fractions.md",
        "word-problems-fractions-addition.md",
        "word-problems-fractions-division.md",
        "word-problems-fractions-multiplication.md",
        "word-problems-fractions-subtraction.md"
    )
    "Geometry" = @(
        "angles.md",
        "area-shapes.md",
        "circles.md",
        "measuring-lines.md",
        "measuring-rectangles.md",
        "perimeter-and-area.md",
        "polygons.md",
        "pythagorean-theorem.md",
        "volume.md",
        "volume-cubes.md"
    )
    "Graph Paper" = @(
        "bar-graphs.md",
        "line-graphs.md",
        "xy-graphs.md"
    )
    "Graphing" = @(
        "make-a-bar-graph.md",
        "make-a-line-graph.md"
    )
    "Measurement" = @(
        "metric-conversion.md",
        "metric-weights-and-measures.md",
        "reading-thermometers.md",
        "temperature-conversion.md",
        "us-weights-and-measures.md"
    )
    "Number Concepts" = @(
        "exponents.md",
        "mean-median-mode-range.md",
        "roman-arabic-comparison.md",
        "roman-numerals.md",
        "roots.md",
        "scientific-notation.md"
    )
    "Number Lines" = @(
        "number-lines---decimals.md",
        "number-lines---fractions.md",
        "number-lines---integers.md"
    )
    "Numeration" = @(
        "associative-property.md",
        "before-after-between.md",
        "circle-the-numbers.md",
        "commutative-property.md",
        "comparing-numbers.md",
        "count-how-many.md",
        "count-up-and-down.md",
        "counting-patterns.md",
        "distributive-property.md",
        "expanded-notation.md",
        "factors.md",
        "greatest-common-factor.md",
        "lowest-common-multiple.md",
        "multiples.md",
        "ordering-numbers.md",
        "place-value.md",
        "prime-numbers.md",
        "rounding-numbers.md"
    )
    "Probability" = @(
        "probability-spinner.md"
    )
    "Puzzles" = @(
        "across-downs.md",
        "addition-box.md",
        "diamond-math.md",
        "magic-squares.md",
        "magic-stars.md",
        "multiplication-box.md",
        "number-patterns.md",
        "secret-trails.md",
        "sudoku.md"
    )
    "Ratio and Percent" = @(
        "percent-and-decimals.md",
        "percent-of-numbers---advanced.md",
        "percent-of-numbers---basic.md",
        "ratio-conversions.md",
        "word-problems-percent.md"
    )
    "Tables and Drills" = @(
        "circle-drill-addition.md",
        "circle-drill-division.md",
        "circle-drill-multiplication.md",
        "circle-drill-subtraction.md",
        "counting-table.md",
        "table-drill-addition.md",
        "table-drill-division.md",
        "table-drill-multiplication.md",
        "table-drill-subtraction.md"
    )
    "Time" = @(
        "telling-time.md",
        "time-conversions.md",
        "time-passages.md"
    )
}

$totalMoved = 0
$totalNotFound = 0
$categoriesProcessed = 0

foreach ($category in $fileMapping.Keys | Sort-Object) {
    $categoryPath = Join-Path $activitiesPath $category
    $files = $fileMapping[$category]
    
    Write-Host "Processing: $category ($($files.Count) files)" -ForegroundColor Yellow
    
    $categoryMoved = 0
    $categoryNotFound = 0
    
    foreach ($fileName in $files) {
        $sourcePath = Join-Path $activitiesPath $fileName
        $destPath = Join-Path $categoryPath $fileName
        
        if (Test-Path $sourcePath) {
            Move-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host "  [MOVED] $fileName" -ForegroundColor Green
            $categoryMoved++
            $totalMoved++
        }
        else {
            Write-Host "  [NOT FOUND] $fileName" -ForegroundColor Red
            $categoryNotFound++
            $totalNotFound++
        }
    }
    
    Write-Host "  Moved: $categoryMoved | Not found: $categoryNotFound" -ForegroundColor Gray
    Write-Host ""
    $categoriesProcessed++
}

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Final Summary:" -ForegroundColor Cyan
Write-Host "  Categories processed: $categoriesProcessed" -ForegroundColor White
Write-Host "  Total files moved: $totalMoved" -ForegroundColor Green
Write-Host "  Total files not found: $totalNotFound" -ForegroundColor Red
Write-Host "===============================================" -ForegroundColor Cyan

if ($totalNotFound -eq 0) {
    Write-Host ""
    Write-Host "Success! All files have been moved into their category folders." -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "Warning: Some files were not found. Review the output above." -ForegroundColor Yellow
}
