$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Frontmatter Update Log.md"
$logContent = @("# Frontmatter Update Log", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Set 'draft: false' in all manual files (Fixed Newlines).", "")

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

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $newContent = $content
    
    # Check for existing frontmatter
    # Regex handles both \r\n and \n
    if ($content -match "(?s)^---\r?\n(.*?)\r?\n---\r?\n") {
        $fmContent = $matches[1]
        if ($fmContent -match "draft:\s*true") {
            $newFm = $fmContent -replace "draft:\s*true", "draft: false"
            $newContent = $content -replace [regex]::Escape($fmContent), $newFm
        } elseif ($fmContent -notmatch "draft:") {
            $newFm = $fmContent + "`ndraft: false"
            $newContent = $content -replace [regex]::Escape($fmContent), $newFm
        }
    } else {
        # Create new frontmatter using backtick-n for real newlines
        $newContent = "---`ndraft: false`n---`n`n" + $content
    }

    if ($newContent -ne $content) {
        # Force UTF8 with no BOM to avoid issues, though Obsidian likes BOM usually
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        $modifiedCount++
        $logContent += "- [x] Updated: $($file.FullName.Substring($dir.Length + 1))"
    }
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Updated frontmatter in $modifiedCount files."
