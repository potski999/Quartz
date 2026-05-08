$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\FixEscapedBrackets Log.md"
$logContent = @("# Fix Escaped Brackets Log", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Fixed double-escaped brackets.", "")

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
        
        # Fix double-escaped brackets: \\ [ becomes \ [
        if ($newLine.Contains("\\[") -or $newLine.Contains("\\[")) {
            $newLine = $newLine.Replace("\\[", "[")
            $newLine = $newLine.Replace("\\]", "]")
            $modified = $true
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