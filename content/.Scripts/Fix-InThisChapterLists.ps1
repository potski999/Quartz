$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\InThisChapter List Fix Log.md"
$logContent = @("# In this Chapter List Fix Log", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Added bullet prefix to unbulleted link lists following '### In this Chapter', removed blank line after heading.", "")

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.DirectoryName -notlike "*\.Scripts*" -and
    $_.Name -notmatch "EBOOK"
}

$modifiedCount = 0

foreach ($file in $files) {
    $lines = Get-Content $file.FullName -Encoding UTF8
    $newLines = @()
    $i = 0
    $modified = $false
    
    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        
        if ($line -match '^### In this Chapter') {
            $newLines += $line
            $i++
            
            # First collect link lines after heading
            $linkLines = @()
            $alreadyBulleted = $false
            $hasBlankLine = $false
            
            while ($i -lt $lines.Count) {
                $nextLine = $lines[$i]
                
                # Track if there's a blank line
                if ($nextLine -match '^\s*$') {
                    $hasBlankLine = $true
                    $i++
                    continue
                }
                
                # Check for links
                if ($nextLine -match '\[\[') {
                    if ($nextLine -match '^\s*[-*]\s') {
                        $alreadyBulleted = $true
                    }
                    $linkLines += $nextLine
                    $i++
                } else {
                    break
                }
            }
            
            # Process collected lines
            if ($linkLines.Count -gt 0) {
                # If not already bulleted, add bullets
                if (-not $alreadyBulleted) {
                    foreach ($ln in $linkLines) {
                        $newLines += "- " + $ln.Trim()
                    }
                    $modified = $true
                } else {
                    # Already bulleted - keep as-is
                    # Remove blank line if present (because we collected separately)
                    if ($hasBlankLine) {
                        $modified = $true
                    }
                    # But still need to add the link lines back
                    foreach ($ln in $linkLines) {
                        $newLines += $ln
                    }
                }
            }
            
            # Add any remaining non-link line
            if ($i -lt $lines.Count) {
                $newLines += $lines[$i]
                $i++
            }
        } else {
            $newLines += $line
            $i++
        }
    }
    
    if ($modified) {
        $finalContent = $newLines -join "`n"
        if (-not $finalContent.EndsWith("`n")) {
            $finalContent = $finalContent + "`n"
        }
        Set-Content -Path $file.FullName -Value $finalContent -Encoding UTF8
        $modifiedCount++
        $logContent += "- [x] Updated: $($file.FullName.Substring($dir.Length + 1))"
    }
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Updated $modifiedCount files."