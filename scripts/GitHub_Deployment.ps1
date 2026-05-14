# GitHub_Deployment.ps1 - Builds site, updates FSS, commits, and pushes
# Usage: .\scripts\GitHub_Deployment.ps1

$quartzPath = "C:\Users\potsk\Documents\GitHub\wis-wiki-manual"
Set-Location -Path $quartzPath

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
Write-Host "--- Starting WIS Manual Update: $timestamp ---" -ForegroundColor Cyan

# 1. Prompt for commit message first (before long-running steps)
$message = Read-Host "Enter commit message"
if ([string]::IsNullOrWhiteSpace($message)) {
    Write-Host "Commit message is empty. Aborting." -ForegroundColor Red
    exit 1
}

# 2. Run the Quartz Build
Write-Host "1. Building Site..." -ForegroundColor Yellow
npx quartz build

# 3. Sync changed files to File Search Store
Write-Host "2. Updating File Search Store for changed files..." -ForegroundColor Yellow
Write-Host "   (3s delay between uploads due to Gemini free-tier rate limits)" -ForegroundColor DarkYellow
python scripts/upload-manager.py --git-diff
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ERROR: FSS upload failed. Deployment aborted to prevent commit" -ForegroundColor Red
    Write-Host "   from losing the change history. Fix the failing files and retry." -ForegroundColor Red
    exit 1
}

# 4. Warn about sync delay
Write-Host "3. NOTE: FSS is now ahead of the live site. Search results may temporarily" -ForegroundColor DarkYellow
Write-Host "   point to pages not yet deployed. This resolves once Firebase finishes." -ForegroundColor DarkYellow
Write-Host "   The search app should handle 404s gracefully (future work)." -ForegroundColor DarkYellow

# 5. Git Stage and Commit
git add .
Write-Host "4. Committing: '$message'..." -ForegroundColor Yellow
git commit -m $message

# 6. Push to GitHub
Write-Host "5. Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin v4

Write-Host "--- SUCCESS! Published WIS-Wiki-Manual at $timestamp ---" -ForegroundColor Green
Start-Sleep -Seconds 5
