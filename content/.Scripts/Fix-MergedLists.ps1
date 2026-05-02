$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Batch Edit Log - Fix Merged Lists.md"
$logContent = @("# Batch Edit Log - Fix Merged Lists", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Split bullet points and glossary terms that were merged into paragraphs.", "")

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { $_.Name -notmatch "War in Spain manual EBOOK" -and $_.FullName -notmatch "\\\.Scripts\\" }

$modifiedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content

    # 1. Split mid-paragraph bullet points: "Text. - Item" -> "Text.\n- Item"
    # Escaping the $1 with ` to ensure it's treated as a regex backreference, not a PS variable.
    $content = $content -replace '(?<=[.\)])\s+-\s+(?=[A-Z])', "`n- "

    # 2. Split bolded glossary terms: "Text. **Term** –" -> "Text.\n\n**Term** –"
    $content = $content -replace '(?<=[.\)])\s+(\*\*[^*]+\*\*\s*[–—-]\s+)', "`n`n`$1"

    # 3. Split unbolded glossary terms: "Text. Term –" -> "Text.\n\nTerm –"
    $content = $content -replace '(?<=[.\)])\s+([A-Z][a-zA-Z0-9\-\x27\u2019]+(?: [a-zA-Z0-9\-\x27\u2019]+){0,3}\s*[–—-]\s+)', "`n`n`$1"

    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $modifiedCount++
        $logContent += "- [x] Updated: $($file.FullName.Substring($dir.Length + 1))"
    }
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Split merged lists in $modifiedCount files."
