$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Batch Edit Log - Bold Definitions.md"
$logContent = @("# Batch Edit Log - Bold Definitions", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Programmatically applied bold formatting to glossary-style terms preceding a dash.", "")

# Non-manual files to exclude from all script checks
$excludedFiles = @(
    "Wiki Phase 2 Plan.md",
    "index.md"
)

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { 
    $_.Name -notmatch "War in Spain manual EBOOK" -and 
    $_.FullName -notmatch "\\\.Scripts\\" -and
    $excludedFiles -notcontains $_.Name
}

$modifiedCount = 0

# Updated Regex to allow brackets and more word variations in glossary terms:
$pattern = '(?m)(^[\s>\*\-]*|\.\s+)([A-Z0-9][a-zA-Z0-9\-\x27\u2019\(\)\[\]\/ ]{1,50})\s*([\u2013\u2014\u002d]\s+)'

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Apply bolding if not already bolded
    $newContent = $content -replace $pattern, '$1**$2** $3'
    
    # Fix spacing bugs (trailing spaces inside bold tags)
    $newContent = $newContent -replace '[ \t]+\*\*[ \t]*([\u2013\u2014\u002d])', '** $1'

    if ($newContent -ne $content) {
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        $modifiedCount++
        $logContent += "- [x] Updated: $($file.FullName.Substring($dir.Length + 1))"
    }
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Bolded terms in $modifiedCount files."
