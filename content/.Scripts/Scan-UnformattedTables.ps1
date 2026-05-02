$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$reportPath = "$dir\.Scripts\Potential Tables Report.md"
$reportLines = [System.Collections.Generic.List[string]]::new()
$reportLines.Add("# Potential Unformatted Tables Report")
$reportLines.Add("**Date:** $(Get-Date -Format 'yyyy-MM-dd')")
$reportLines.Add("**Description:** Heuristic scan to find text that looks like a table but is not formatted as a Markdown table (e.g., columns separated by tabs or multiple spaces).")
$reportLines.Add("")

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.DirectoryName -notlike "*\.Scripts*" -and
    $_.Name -notmatch "EBOOK|index.md|Wiki Phase 2 Plan.md"
}

$foundCount = 0

foreach ($file in $files) {
    # Skip files that already have markdown tables (simplification)
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Heuristic: Find 3+ lines in a row that contain tabs or multiple spaces between words
    # and do NOT start with markdown list markers or pipes.
    $lines = $content -split "`n"
    $potentialTableLines = @()
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()
        if ($line.Length -lt 10) { continue }
        
        # Check for tab or 4+ spaces separating alphanumeric characters
        if ($line -match "[a-zA-Z0-9]\t+[a-zA-Z0-9]" -or $line -match "[a-zA-Z0-9] {4,}[a-zA-Z0-9]") {
            if ($line -notmatch "^\|" -and $line -notmatch "^[\-\*\+] ") {
                $potentialTableLines += "$($i+1): $line"
            }
        } else {
            if ($potentialTableLines.Count -ge 2) {
                $relativePath = $file.FullName.Substring($dir.Length + 1)
                $reportLines.Add("### $relativePath")
                foreach ($ptl in $potentialTableLines) {
                    $reportLines.Add("- $ptl")
                }
                $reportLines.Add("")
                $foundCount++
            }
            $potentialTableLines = @()
        }
    }
}

Set-Content -Path $reportPath -Value $reportLines -Encoding UTF8
Write-Host "Found $foundCount potential unformatted tables."
