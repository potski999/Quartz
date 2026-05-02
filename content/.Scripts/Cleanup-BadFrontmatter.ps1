$dir = "c:\Users\potsk\Documents\Obsidian\Vault\WIS Manual"

$files = Get-ChildItem -Path $dir -Recurse -Filter "*.md" | Where-Object { $_.DirectoryName -notlike "*\.Scripts*" }

$count = 0
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Using a literal match for the broken string
    if ($content -match '---(\\n)draft: false(\\n)---(\\n)(\\n)') {
        $newContent = $content -replace '---(\\n)draft: false(\\n)---(\\n)(\\n)', ''
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        $count++
    }
}

Write-Host "Cleaned up $count files."
