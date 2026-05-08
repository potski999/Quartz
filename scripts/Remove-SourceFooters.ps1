$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Footer Removal Log V2.md"
$logContent = @("# Footer Removal Log V2", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Removed 'Original Source Reference' footers from manual files.", "")

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

$modifiedCount = 0

# More flexible pattern:
# Optional whitespace
# Horizontal rule (***)
# Callout header
# Everything until end of file
$pattern = '(?s)\s*\r?\n\*\*\*\r?\n>\s*\[!note\]-\s*Original Source Reference.*'

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    if ($content -match $pattern) {
        $newContent = $content -replace $pattern, ''
        # Final cleanup: ensure single trailing newline
        $newContent = $newContent.TrimEnd() + "`r`n"
        
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        $modifiedCount++
        $logContent += "- [x] Removed footer from: $($file.FullName.Substring($dir.Length + 1))"
    }
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Removed footers from $modifiedCount files."
