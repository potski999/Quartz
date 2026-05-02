$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$reportPath = "$dir\.Scripts\Broken CrossRef Report.md"
$reportLines = [System.Collections.Generic.List[string]]::new()
$reportLines.Add("# Broken Cross-Reference Report")
$reportLines.Add("**Date:** $(Get-Date -Format 'yyyy-MM-dd')")
$reportLines.Add("**Description:** Scans for links like [[File|section X]].Y where the trailing .Y is dangling outside brackets.")
$reportLines.Add("")

# Non-manual files to exclude from all script checks
$excludedFiles = @(
    "Wiki Phase 2 Plan.md",
    "index.md"
)

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.DirectoryName -notlike "*\.Scripts*" -and
    $_.Name -notmatch "EBOOK" -and
    $excludedFiles -notcontains $_.Name
}

# Build lookup table: section-number prefix -> filename (without extension)
$fileMap = @{}
foreach ($f in $files) {
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $sectionMatch = [regex]::Match($baseName, '^[\d\.]+')
    if ($sectionMatch.Success) {
        $fileMap[$sectionMatch.Value] = $baseName
    }
}

$totalMatches = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $relativePath = $file.FullName.Substring($dir.Length + 1)
    
    # Find patterns like [[Some File|alias]].N or [[Some File]].N
    $regex = [regex]'\[\[([^\]]+)\]\](\.\d+(\.\d+)*)'
    $foundMatches = $regex.Matches($content)
    
    foreach ($m in $foundMatches) {
        $fullMatch  = $m.Value
        $innerLink  = $m.Groups[1].Value    # e.g. "8.2.3 Combat Orders Screen|section 8.2.3"
        $dangling   = $m.Groups[2].Value    # e.g. ".2" or ".2.6"
        
        # Extract the file-reference part (before the | alias if present)
        $filePart = ($innerLink -split '\|')[0].Trim()
        
        # Extract leading section number from the file part
        $secMatch = [regex]::Match($filePart, '^[\d\.]+')
        $baseSection  = $secMatch.Value
        $fullSection  = $baseSection + $dangling   # e.g. "8.2.3.2"
        
        # Check if a file exists for the full section
        $targetFile = $fileMap[$fullSection]
        
        $approxLine = ($content.Substring(0, $m.Index) -split "`n").Count
        
        if ($targetFile) {
            $reportLines.Add("- **[$relativePath ~L$approxLine]** MATCH: $fullMatch")
            $reportLines.Add("  - Intended section: $fullSection")
            $reportLines.Add("  - Target file exists: $targetFile")
            $reportLines.Add("  - Status: **CAN AUTO-FIX**")
        } else {
            $reportLines.Add("- **[$relativePath ~L$approxLine]** MATCH: $fullMatch")
            $reportLines.Add("  - Intended section: $fullSection")
            $reportLines.Add("  - Status: **MANUAL REVIEW** (no file found for $fullSection)")
        }
        $reportLines.Add("")
        $totalMatches++
    }
}

if ($totalMatches -eq 0) {
    $reportLines.Add("### All Clear! No broken cross-references found.")
}

$reportLines.Add("---")
$reportLines.Add("Total found: $totalMatches")

Set-Content -Path $reportPath -Value $reportLines -Encoding UTF8
Write-Host "Found $totalMatches broken cross-references."
