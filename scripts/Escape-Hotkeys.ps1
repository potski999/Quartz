$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Batch Edit Log - Escape Hotkeys.md"
$logContent = @("# Batch Edit Log - Escape Hotkeys", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Escaped single brackets used for hotkey references to prevent Markdown misinterpretation.", "")

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { $_.Name -notmatch "War in Spain manual EBOOK" -and $_.FullName -notmatch "\\\.Scripts\\" }

$modifiedCount = 0

# Regex for single-bracket hotkeys and UI elements:
# Matches single brackets [ ] that are NOT part of [[ ]] 
# and contain up to 30 chars of typical key/UI text.
$pattern = '(?<!\\)(?<!\[)\[([A-Za-z0-9\+\-\*\/\.\/ ]{1,30}|Num Pad [^\x5D]+)\](?!\])'

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Replace [Key] with \[Key\]
    $newContent = $content -replace $pattern, '\[$1\]'

    if ($newContent -ne $content) {
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        $modifiedCount++
        $logContent += "- [x] Updated: $($file.FullName.Substring($dir.Length + 1))"
    }
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Escaped hotkeys in $modifiedCount files."
