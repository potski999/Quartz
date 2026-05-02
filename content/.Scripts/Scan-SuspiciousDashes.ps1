$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Suspicious Dash Report.md"
$logContent = @("# Suspicious Dash & Flattened List Report", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Description:** A heuristic scan to identify bullet points or glossary terms that were incorrectly merged into the middle of a paragraph during PDF extraction.", "")

# Non-manual files to exclude from all script checks
$excludedFiles = @(
    "Wiki Phase 2 Plan.md",
    "index.md"
)

# Exempted files (different authors/styles - valid em-dash usage)
$exemptions = @("22 Designers Notes.md", "1.1 New Game Engine.md")

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.Name -notmatch "War in Spain manual EBOOK" -and 
    $_.FullName -notmatch "\\\.Scripts\\" -and
    $excludedFiles -notcontains $_.Name -and
    $exemptions -notcontains $_.Name
}

$totalMatches = 0
$filesFlagged = 0

# Unicode escapes:
# \u2013 = En-Dash (–)
# \u2014 = Em-Dash (—)
# \u002d = Hyphen (-)
$dashClass = '[\u2013\u2014\u002d]'

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Encoding UTF8
    $fileMatches = @()
    
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        $lineNumber = $i + 1
        
        # Rule 1: Ignore lines already bolded correctly (allowing hotkeys in between)
        if ($line -match '\*\*[^*]+\*\*.*[\u2013\u2014\u002d]') {
            continue
        }

        # Rule 2: Skip short lines
        if ($line.Trim().Length -lt 20) { continue }
        
        # Rule 3: Exceptions for math, coordinates, and game title
        # Ignore "+ and -"
        if ($line -match '\+ and [\u2013\u2014\u002d]') { continue }
        # Ignore dash followed by a digit (likely a negative coordinate or number range)
        if ($line -match '[\u2013\u2014\u002d]\s*\d+') { continue }
        
        $cleanLine = $line -replace '1936[\u2013\u2014\u002d]39', '1936_39'

        $matchReason = $null
        
        # Check for mid-paragraph em-dash or en-dash (at least 20 chars into the text)
        if ($cleanLine -match ".{20,}[\u2013\u2014]") {
            $matchReason = "Mid-paragraph em-dash"
        }
        # Check for mid-paragraph regular dash used as a list item
        elseif ($cleanLine -match '.{20,}\s-\s[A-Z]') {
            $matchReason = "Mid-paragraph spaced dash (-)"
        }

        if ($matchReason) {
            $excerpt = $line.Trim()
            if ($excerpt.Length -gt 150) { $excerpt = $excerpt.Substring(0, 150) + "..." }
            $fileMatches += "- **Line ${lineNumber}:** [$matchReason] ``$excerpt``"
        }
    }
    
    if ($fileMatches.Count -gt 0) {
        $relativePath = $file.FullName.Substring($dir.Length + 1)
        $logContent += "### $relativePath"
        $logContent += $fileMatches
        $logContent += ""
        $totalMatches += $fileMatches.Count
        $filesFlagged++
    }
}

if ($totalMatches -eq 0) {
    $logContent += "### All Clear! No suspicious mid-paragraph lists found."
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Found $totalMatches suspicious locations across $filesFlagged files."
