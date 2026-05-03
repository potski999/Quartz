$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\ItalicizeWiS Final Log.md"
$logContent = @("# Italicize War in Spain Final Log", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** All 'War in Spain 1936-39' to italics (*text*) - plain, bold, or bold+italic.", "")

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.DirectoryName -notlike "*\.Scripts*" -and
    $_.Name -notmatch "EBOOK"
}

$modifiedCount = 0

foreach ($file in $files) {
    $lines = Get-Content $file.FullName -Encoding UTF8
    $newLines = @()
    $modified = $false
    
    foreach ($line in $lines) {
        $newLine = $line
        
        # Skip headings and links
        if ($line -notmatch '^#' -and $line -notmatch '\[\[') {
            # Convert bold+italic (***) to italic (*)
            if ($newLine.Contains("***War in Spain 1936-39***")) {
                $newLine = $newLine.Replace("***War in Spain 1936-39***", "*War in Spain 1936-39*")
                $modified = $true
            }
            # Convert bold (**) to italic (*)
            elseif ($newLine.Contains("**War in Spain 1936-39**")) {
                $newLine = $newLine.Replace("**War in Spain 1936-39**", "*War in Spain 1936-39*")
                $modified = $true
            }
            # Convert plain text to italic (*)
            elseif ($newLine.Contains("War in Spain 1936-39")) {
                $newLine = $newLine.Replace("War in Spain 1936-39", "*War in Spain 1936-39*")
                $modified = $true
            }
        }
        
        $newLines += $newLine
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