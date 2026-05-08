@echo off
chcp 65001 >nul
setlocal

set GITHUB_USERNAME=k22614775-spec
set REPO_NAME=smooth-erp

echo.
echo =========================================
echo  Push smooth-erp to GitHub
echo =========================================
echo.

REM Check git
where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: git not found. Please install Git for Windows first.
    echo https://git-scm.com/download/win
    pause
    exit /b 1
)

cd /d "%~dp0"

git init
git config user.email "k22614775@gmail.com"
git config user.name "andy fu"
git add -A
git commit -m "feat: ERP+MES Supabase migration v1.0"
git branch -M main
git remote remove origin >nul 2>&1
git remote add origin https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git
git push -u origin main

echo.
echo =========================================
echo  Done! Next steps:
echo  1. GitHub Repo Settings > Pages > GitHub Actions
echo  2. Settings > Secrets > add SUPABASE_URL and SUPABASE_ANON_KEY
echo =========================================
pause
