$vaultPath = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$files = Get-ChildItem -Path $vaultPath -Filter "*.md" -Recurse | Where-Object { $_.FullName -notmatch "\\\.Scripts\\" }

$migratedCount = 0

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    
    # Check if the file has the tag we want to replace
    if ($content -match "tag:\s*KB_Compile") {
        # 1. Add ai_search: true if not present
        if ($content -notmatch "ai_search:") {
            # Insert before the closing ---
            $content = $content -replace "(---[\s\S]*?)(---)", "`$1ai_search: true`n`$2"
        }
        
        # 2. Remove the old tag
        $content = $content -replace "tag:\s*KB_Compile\s*[\r\n]*", ""
        
        # 3. Ensure no trailing empty lines in frontmatter
        $content = $content -replace "\n\s*\n---", "`n---"
        
        [System.IO.File]::WriteAllText($file.FullName, $content)
        $migratedCount++
        # Write-Host "Migrated: $($file.FullName)"
    }
}

Write-Output "Successfully migrated $migratedCount files from 'tag: KB_Compile' to 'ai_search: true'."
