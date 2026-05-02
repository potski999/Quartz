$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$reportPath = "$dir\.Scripts\Manual Cleanup Report (Sections 9-25).md"
$reportLines = [System.Collections.Generic.List[string]]::new()
$reportLines.Add("# Manual Cleanup Report (Sections 9-25)")
$reportLines.Add("**Date:** $(Get-Date -Format 'yyyy-MM-dd')")
$reportLines.Add("**Scope:** Heuristic analysis of missing media, unformatted tables, and suspicious formatting in manual sections 9 through 25.")
$reportLines.Add("")

# Correctly filter for sections 9-25
$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.DirectoryName -notlike "*\.Scripts*" -and
    $_.Name -notmatch "EBOOK|index.md|Wiki Phase 2 Plan.md" -and
    ($_.Name -match "^9\." -or $_.Name -match "^[12][0-9]\.")
}

$reportLines.Add("## Summary of Findings")
$reportLines.Add("- Total Files Scanned: $($files.Count)")
$reportLines.Add("")

$mediaTriggers = @(
    "this screen shows", "the image below", "see image", "the dialog box", 
    "the sidebar shows", "indicated in green", "shown in red", "highlighted area",
    "the following screen", "the map shows", "this icon"
)

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $relativePath = $file.FullName.Substring($dir.Length + 1)
    $fileIssues = [System.Collections.Generic.List[string]]::new()

    # 1. Missing Media
    $hasImage = $content -match "!\[\[.*?\]\]|!\[.*?\]\(.*?\)"
    if (-not $hasImage) {
        foreach ($trigger in $mediaTriggers) {
            if ($content -match "(?i)$([regex]::Escape($trigger))") {
                $lines = $content -split "`r?`n"
                for ($i=0; $i -lt $lines.Count; $i++) {
                    if ($lines[$i] -match "(?i)$([regex]::Escape($trigger))") {
                        $snippet = $lines[$i].Trim()
                        if ($snippet.Length -gt 100) { $snippet = $snippet.Substring(0, 100) + "..." }
                        $fileIssues.Add("- **Missing Media?** L$($i+1): Referenced '$trigger' - ``$snippet``")
                        break
                    }
                }
            }
        }
    }

    # 2. Unformatted Tables (Case-sensitive check for uppercase runs)
    if ($content -notmatch '\|' -and $content.Length -gt 100) {
        $lines = $content -split "`r?`n"
        foreach ($line in $lines) {
            $trimmed = $line.Trim()
            # Use -cmatch for case-sensitivity
            if ($trimmed.Length -gt 40 -and $trimmed -cmatch '([A-Z]{2,}\s+){3,}') {
                $fileIssues.Add("- **Flattened Table?** Likely unformatted data: ``$($trimmed.Substring(0, [math]::Min(60, $trimmed.Length)))``")
                break
            }
        }
    }

    # 3. Suspicious Dashes (Case-sensitive check)
    if ($content -cmatch "[a-z][\u2013\u2014\u002d][A-Z]") {
        $fileIssues.Add("- **Suspicious Dash:** Found merged line/bullet (e.g., `word-Word`)")
    }

    if ($fileIssues.Count -gt 0) {
        $reportLines.Add("### [$relativePath](file:///$($file.FullName.Replace('\','/')))")
        foreach ($issue in $fileIssues) {
            $reportLines.Add($issue)
        }
        $reportLines.Add("")
    }
}

Set-Content -Path $reportPath -Value $reportLines -Encoding UTF8
Write-Host "Cleanup report generated for $($files.Count) files."
