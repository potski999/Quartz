$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Missing Media Report.md"
$logContent = @("# Missing Images and Tables Analysis Report", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Description:** A refined heuristic scan to identify specific files that are missing embedded screenshots, images, or tables, excluding any files that already contain an image or a table.", "")

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { $_.Name -notmatch "War in Spain manual EBOOK" -and $_.FullName -notmatch "\\\.Scripts\\" }

$totalMatches = 0
$filesFlagged = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Encoding UTF8
    
    # Pre-check: Does this file already have an image or a table?
    $hasMedia = $false
    foreach ($line in $content) {
        if ($line -match '!\[' -or $line -match '(?i)\.(png|jpg|jpeg)\b' -or $line -match '\|\s*[-:]+\s*\|') {
            $hasMedia = $true
            break
        }
    }
    
    if ($hasMedia) {
        continue
    }

    $fileMatches = @()
    
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        $lineNumber = $i + 1
        
        $matchReason = $null
        
        if ($line -match '(?i)\b(table|figure|image|screenshot|chart|map)\s+(below|above)\b') {
            $matchReason = "Mentions graphic positioned relative"
        }
        elseif ($line -match '(?i)(as shown|see)\s+(in the |the |this )?(table|figure|image|screenshot|chart|map)?\s*(below|above)') {
            $matchReason = "Mentions 'as shown/see below'"
        }
        elseif ($line -match '(?i)as shown in (the|this) (image|screenshot)') {
            $matchReason = "Mentions 'as shown in image'"
        }
        elseif ($line -match '(?i)\bthis screen shows\b') {
            $matchReason = "Mentions 'this screen shows'"
        }
        elseif ($line -match '(?i)\bthe image below\b') {
            $matchReason = "Mentions 'the image below'"
        }
        elseif ($line -match '(?i)\b(see|shown in) (the )?image\b') {
            $matchReason = "Mentions 'see image'"
        }
        elseif ($line -match '^(?i)(Figure|Fig\.|Table|Chart|Screenshot)\s*\d*[\.\-:]?\s+') {
            $matchReason = "Looks like a caption"
        }
        elseif ($line -match '^(?i)(Table|Screenshot|Image)\s*$') {
            $matchReason = "Orphaned graphic label"
        }
        
        if ($matchReason) {
            # Filter out cross-references
            if ($line -notmatch '(?i)\b(in section|see section|chapter)\b') {
                $excerpt = $line.Trim()
                if ($excerpt.Length -gt 100) { $excerpt = $excerpt.Substring(0, 100) + "..." }
                $fileMatches += "- **Line ${lineNumber}:** [$matchReason] ``$excerpt``"
            }
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
    $logContent += "### All Clear! No missing media locations found."
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Found $totalMatches missing media locations across $filesFlagged files."
