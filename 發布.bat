@echo off
chcp 65001 >nul
cd /d "C:\Users\andy\Desktop\誼冠\CLAUDE4.6\smooth-erp"
echo ========================================
echo   smooth-erp 一鍵發布
echo ========================================
del /f /s /q ".git\*.lock" >nul 2>&1
git add -A
git commit -m "chore: 一鍵發布"
git push origin main
echo.
echo 完成。約 1-3 分鐘後檢查：
echo   Actions: https://github.com/k22614775-spec/smooth-erp/actions
echo   網站:    https://k22614775-spec.github.io/smooth-erp/
pause
