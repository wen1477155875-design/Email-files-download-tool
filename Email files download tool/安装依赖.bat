@echo off
setlocal
cd /d "%~dp0"
echo ============================================================
echo  邮件附件下载工具 - 首次部署：创建虚拟环境并安装依赖
echo ============================================================
echo.

set "PY="
where py >nul 2>nul
if not errorlevel 1 set "PY=py -3"
if defined PY goto have_py
where python >nul 2>nul
if not errorlevel 1 set "PY=python"
if defined PY goto have_py
echo [错误] 未找到 Python，请先安装 Python 3.10+
echo        安装时勾选 tcl/tk 和 Add Python to PATH
pause
exit /b 1

:have_py
echo [1/3] 使用解释器: %PY%
echo [2/3] 创建虚拟环境 .venv ...
%PY% -m venv .venv
if errorlevel 1 goto fail_venv

echo [3/3] 安装依赖 pywin32 / PyYAML（清华镜像）...
.venv\Scripts\python.exe -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --disable-pip-version-check
if errorlevel 1 goto fail_pip

echo.
echo 正在运行离线自检（不连真实 Outlook）...
.venv\Scripts\python.exe smoke_test.py
if errorlevel 1 goto fail_test

echo.
echo ============================================================
echo  部署完成！双击 启动界面.bat 打开图形界面
echo ============================================================
pause
exit /b 0

:fail_venv
echo [错误] 创建虚拟环境失败
pause
exit /b 1

:fail_pip
echo [错误] 依赖安装失败，请检查网络（或把镜像地址换成公司内网源）后重试
pause
exit /b 1

:fail_test
echo [错误] 自检未通过，请把上面的输出发回来排查
pause
exit /b 1
