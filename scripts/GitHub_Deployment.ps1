# Github_Push.ps1 - Stages, commits, and pushes to GitHub for WIS-Wiki-Manual
# Usage: .\scripts\Github_Push.ps1

# 1. Set your Quartz folder path
$quartzPath = "C:\Users\potsk\Documents\GitHub\wis-wiki-manual"
Set-Location -Path $quartzPath

# 2. Create a clean Timestamp (e.g., 2024-05-20 14:30)
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMessage = "WIS Manual Update [$timestamp]"

Write-Host "--- Starting WIS Manual Update: $timestamp ---" -ForegroundColor Cyan

# 3. Run the Quartz Build
Write-Host "1. Building Site..." -ForegroundColor Yellow
npx quartz build

# 4. Prompt for commit message
$message = Read-Host "Enter commit message"
if ([string]::IsNullOrWhiteSpace($message)) {
    Write-Host "Commit message is empty. Aborting." -ForegroundColor Red
    exit 1
}

# 5. Git Stage and Commit using message
git add .
Write-Host "2. Committing: '$message'..." -ForegroundColor Yellow
git commit -m $message

# 5. Push to GitHub
Write-Host "3. Pushing to GitHub..." -ForegroundColor Yellow
git push origin v4

Write-Host "--- SUCCESS! Published WIS-Wiki-Manual at $timestamp ---" -ForegroundColor Green
Start-Sleep -Seconds 5
