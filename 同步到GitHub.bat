@echo off
chcp 936 >nul 2>&1
setlocal
cd /d "%~dp0"
title 光影印章 - 同步到 GitHub

echo ==========================================
echo    光影印章  同步到 GitHub
echo ==========================================
echo.

where git >nul 2>&1
if errorlevel 1 goto NOGIT

git rev-parse --git-dir >nul 2>&1
if errorlevel 1 goto NOTREPO

git remote get-url origin >nul 2>&1
if errorlevel 1 goto SETUP
goto SYNC


:NOGIT
echo [错误] 系统里找不到 git 命令。
echo 请先安装 Git for Windows: https://git-scm.com/download/win
echo.
pause
exit /b 1


:NOTREPO
echo [错误] 这个脚本必须放在项目文件夹里，和 index.html 放在一起。
echo 当前所在目录: %CD%
echo.
echo 请到项目文件夹里双击它，不要单独把它复制到别的地方。
echo.
pause
exit /b 1


:SETUP
echo [首次配置] 还没关联 GitHub 仓库，先做一次设置。
echo.
echo 前提：你已经在 GitHub 建好了空仓库，名字叫 photo-exif-stamp
echo 建仓库时不要勾选 Add a README / .gitignore / license
echo.
set "GHUSER="
set /p GHUSER=  请输入你的 GitHub 用户名，然后回车: 
if not defined GHUSER goto NOUSER
git remote add origin "https://github.com/%GHUSER%/photo-exif-stamp.git"
echo.
echo   已关联: https://github.com/%GHUSER%/photo-exif-stamp.git

set "CURNAME="
for /f "delims=" %%i in ('git config user.name 2^>nul') do set "CURNAME=%%i"
if defined CURNAME goto NAMEOK
git config user.name "%GHUSER%"
echo   提交署名: %GHUSER%
:NAMEOK
set "CUREMAIL="
for /f "delims=" %%i in ('git config user.email 2^>nul') do set "CUREMAIL=%%i"
if defined CUREMAIL goto EMAILOK
git config user.email "%GHUSER%@users.noreply.github.com"
:EMAILOK
echo.


:SYNC
echo 正在检查改动...
git add -A
git diff --cached --quiet
if errorlevel 1 goto DOCOMMIT
echo   没有新改动，直接推送。
goto DOPUSH

:DOCOMMIT
git commit -m "更新 - %date% %time%" >nul 2>nul
echo   已记录本地改动。

:DOPUSH
echo.
echo 正在推送到 GitHub，第一次会弹出登录窗口，登录一次以后就记住。
echo.
git push -u origin main
if errorlevel 1 goto PUSHFAIL

echo.
echo ==========================================
echo   同步完成
echo   GitHub Pages 约 1-2 分钟后自动更新
echo ==========================================
echo.
pause
exit /b 0


:NOUSER
echo.
echo 没有输入内容，已取消。请重新双击运行。
echo.
pause
exit /b 1


:PUSHFAIL
echo.
echo [失败] 没能推上去。常见原因:
echo   1. 仓库还没在 GitHub 上创建
echo   2. 用户名拼错了
echo   3. 弹出的登录窗口被关掉了
echo.
echo 把上面报错那几行截图发给老大看就行。
echo.
pause
exit /b 1
