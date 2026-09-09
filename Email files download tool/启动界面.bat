@echo off
setlocal
cd /d "%~dp0"
if exist ".venv\Scripts\pythonw.exe" goto use_venv
if exist "python_env.txt" goto use_env
where pythonw >nul 2>nul
if not errorlevel 1 goto use_path
echo [提示] 未找到 Python 环境，请先运行 安装依赖.bat
pause
exit /b 1

:use_venv
start "" ".venv\Scripts\pythonw.exe" ui.py
exit /b 0

:use_env
set /p PYW=<python_env.txt
start "" %PYW% ui.py
exit /b 0

:use_path
start "" pythonw ui.py
exit /b 0
