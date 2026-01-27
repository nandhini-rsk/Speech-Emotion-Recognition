# Git Commit Date Changer - Reliable Method
# Uses git commit --amend to change dates

Write-Host "=== Changing Git Commit Dates ===" -ForegroundColor Cyan
Write-Host ""

# Create backup
$backup = "backup-final-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
git branch $backup
Write-Host "Backup created: $backup" -ForegroundColor Green
Write-Host ""

# Get current branch
$currentBranch = git branch --show-current

# Define the commits and their new dates
$commits = @(
    @{msg="Add frontend setup and API integration"; date="2026-01-25T09:30:00+05:30"},
    @{msg="Add model training script"; date="2026-01-25T14:45:00+05:30"},
    @{msg="Add testing utilities and improve error handling"; date="2026-01-25T18:20:00+05:30"},
    @{msg="Add deployment configurations for Vercel and Railway"; date="2026-01-26T10:15:00+05:30"},
    @{msg="Fix Railway build configuration"; date="2026-01-26T15:30:00+05:30"},
    @{msg="Add requirements.txt to root for Railway deployment"; date="2026-01-26T19:45:00+05:30"}
)

Write-Host "Changing dates for 6 commits..." -ForegroundColor Yellow
Write-Host ""

# Use interactive rebase with exec commands
$rebaseScript = "#!/bin/sh`n"
foreach ($commit in $commits) {
    $rebaseScript += "GIT_COMMITTER_DATE='$($commit.date)' git commit --amend --no-edit --date='$($commit.date)'`n"
}

# Save rebase script
$rebaseScript | Out-File -FilePath ".git\rebase-script.sh" -Encoding ASCII

# Start interactive rebase from the initial commit
git rebase -i --root --exec "sh .git/rebase-script.sh"

Write-Host ""
Write-Host "Done! New history:" -ForegroundColor Green
git log --pretty=format:"%h - %ad - %s" --date=format:"%Y-%m-%d %H:%M" -n 10

Write-Host ""
Write-Host ""
Write-Host "To push:" -ForegroundColor Yellow
Write-Host "  git push origin main --force" -ForegroundColor Red
Write-Host ""
Write-Host "To undo:" -ForegroundColor Gray
Write-Host "  git reset --hard $backup" -ForegroundColor Gray
