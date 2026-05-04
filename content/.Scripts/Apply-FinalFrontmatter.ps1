$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$logPath = "$dir\.Scripts\Frontmatter Update Log.md"
$logContent = @("# Frontmatter Update Log", "**Date:** $(Get-Date -Format 'yyyy-MM-dd')", "**Action:** Applied 'type: WIS_Manual', 'tag: KB_Compile', and 'draft: false' to all manual files.", "")

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
    # Remove BOM if present
    if ($content.StartsWith("`uFEFF")) {
        $content = $content.Substring(1)
    }
    $newContent = $content
    
    # Check for existing frontmatter
    if ($content -match "(?s)^---\r?\n(.*?)\r?\n---\r?\n") {
        $fmContent = $matches[1]
        $newFm = $fmContent
        
        # Handle draft: false
        if ($newFm -match "draft:\s*true") {
            $newFm = $newFm -replace "draft:\s*true", "draft: false"
        } elseif ($newFm -notmatch "draft:") {
            $newFm = $newFm + "`ndraft: false"
        }
        
        # Handle type: WIS_Manual
        if ($newFm -match "type:\s*\w+") {
            $newFm = $newFm -replace "type:\s*\w+", "type: WIS_Manual"
        } elseif ($newFm -notmatch "type:") {
            $newFm = $newFm + "`ntype: WIS_Manual"
        }
        
        # Handle ai_search: true
        if ($newFm -notmatch "ai_search:") {
            $newFm = $newFm + "`nai_search: true"
        }
        
        $newContent = $content -replace [regex]::Escape($fmContent), $newFm
    } else {
        # Create new frontmatter
        $newContent = "---`ndraft: false`ntype: WIS_Manual`nai_search: true`n---`n`n" + $content
    }

    if ($newContent -ne $content) {
        # Ensure file ends with newline
        if (-not $newContent.EndsWith("`n")) {
            $newContent = $newContent + "`n"
        }
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        $modifiedCount++
        $logContent += "- [x] Updated: $($file.FullName.Substring($dir.Length + 1))"
    }
}

Set-Content -Path $logPath -Value $logContent -Encoding UTF8
Write-Host "Updated frontmatter in $modifiedCount files."