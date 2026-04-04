# 1. Set your Quartz folder path
$quartzPath = "C:\Users\potsk\Documents\GitHub\quartz"
Set-Location -Path $quartzPath

# 2. Create a clean Timestamp (e.g., 2024-05-20 14:30)
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMessage = "WIS Manual Update [$timestamp]"

Write-Host "--- Starting WIS Manual Update: $timestamp ---" -ForegroundColor Cyan

# 3. Run the Quartz Build
Write-Host "1. Building Site..." -ForegroundColor Yellow
npx quartz build

# 4. Git Stage and Commit with the Timestamp
Write-Host "2. Committing Changes with Timestamp..." -ForegroundColor Yellow
git add .
git commit -m $commitMessage

# 5. Push to GitHub
Write-Host "3. Pushing to GitHub..." -ForegroundColor Yellow
git push origin v4

Write-Host "--- SUCCESS! Published at $timestamp ---" -ForegroundColor Green
Start-Sleep -Seconds 5
