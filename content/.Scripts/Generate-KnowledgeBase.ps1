$vaultPath = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"
$outputPath = "$vaultPath\.Scripts\knowledge_base.json"
$files = Get-ChildItem -Path $vaultPath -Filter "*.md" -Recurse | Where-Object { $_.FullName -notmatch "\\\.Scripts\\" }

$kb = @()

function Get-Slug($name) {
    # Quartz replaces spaces with hyphens, preserves dots and parentheses
    return $name.Replace(" ", "-")
}

foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName)
    
    # Filter for ai_search: true
    if ($content -match "ai_search:\s*true") {
        # Extract Title from Frontmatter or Filename
        $title = $file.BaseName
        if ($content -match "title:\s*(.*)") {
            $title = $matches[1].Trim().Trim('"').Trim("'")
        }

        # Generate Slug (Quartz Style)
        $fileSlug = Get-Slug($file.BaseName)
        $parentFolder = Split-Path $file.Directory -Leaf
        
        # Build URL (Relative to domain root)
        if ($parentFolder -eq "WIS Manual") {
            # Files in the root of the vault (like index.md)
            if ($fileSlug -eq "index") {
                $url = "/manual/"
            } else {
                $url = "/manual/$fileSlug"
            }
        } else {
            $folderSlug = Get-Slug($parentFolder)
            $url = "/manual/$folderSlug/$fileSlug"
        }

        # Extract clean content (strip frontmatter)
        $cleanContent = $content -replace "(?s)^---.*?---", ""
        $cleanContent = $cleanContent.Trim()

        # Extract terms/keywords (if present)
        $terms = @()
        if ($content -match "terms:\s*\[(.*?)\]") {
            $terms = $matches[1].Split(",") | ForEach-Object { $_.Trim().Trim('"').Trim("'") }
        }

        $kb += [PSCustomObject]@{
            title   = $title
            url     = $url
            content = $cleanContent
            terms   = $terms
        }
    }
}

$kb | ConvertTo-Json -Depth 10 | Set-Content -Path $outputPath -Encoding utf8
Write-Output "Knowledge Base generated with $($kb.Count) sections at $outputPath"
