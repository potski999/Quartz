$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$reportPath = "$dir\.Scripts\Embedded Subsections Report.md"
$reportLines = [System.Collections.Generic.List[string]]::new()
$reportLines.Add("# Embedded Subsections Report")
$reportLines.Add("**Date:** $(Get-Date -Format 'yyyy-MM-dd')")
$reportLines.Add("**Description:** Identifies files containing sub-section numbers (e.g., 7.5.2.1 inside 7.5.2) that may need to be split into standalone files.")
$reportLines.Add("")

# Non-manual files to exclude
$excludedFiles = @(
    "Wiki Phase 2 Plan.md",
    "index.md"
)

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.DirectoryName -notlike "*\.Scripts*" -and
    $_.Name -notmatch "EBOOK" -and
    $excludedFiles -notcontains $_.Name
}

$totalMatches = 0

foreach ($file in $files) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $sectionMatch = [regex]::Match($baseName, '^(\d+(\.\d+)+)')
    
    if (-not $sectionMatch.Success) { continue }
    
    $parentSection = $sectionMatch.Value
    # Escape dots for regex
    $escapedParent = $parentSection.Replace(".", "\.")
    # Look for parent.digits (e.g. 7.5.2.1)
    $subSectionPattern = "(?m)^(?:\s*|###\s*)($escapedParent\.\d+)\s"
    
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $matches = [regex]::Matches($content, $subSectionPattern)
    
    if ($matches.Count -gt 0) {
        $relativePath = $file.FullName.Substring($dir.Length + 1)
        $reportLines.Add("### [$relativePath](file:///$($file.FullName.Replace('\','/')))")
        
        foreach ($m in $matches) {
            $subSec = $m.Groups[1].Value
            $approxLine = ($content.Substring(0, $m.Index) -split "`n").Count
            $reportLines.Add("- Found **$subSec** at L$approxLine")
            $totalMatches++
        }
        $reportLines.Add("")
    }
}

if ($totalMatches -eq 0) {
    $reportLines.Add("### No embedded sub-sections found.")
}

$reportLines.Add("---")
$reportLines.Add("Total sub-sections found: $totalMatches")

Set-Content -Path $reportPath -Value $reportLines -Encoding UTF8
Write-Host "Found $totalMatches embedded sub-sections across several files."
