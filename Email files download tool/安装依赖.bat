@echo off
setlocal
cd /d "%~dp0"
echo ============================================================
echo  邮件附件下载工具 - 依赖安装（自动检测可用的 Python）
echo ============================================================
echo.

rem 若之前跑旧版脚本留下半成品 venv，先清掉
if exist ".venv" rmdir /s /q ".venv"

set "PYCMD="

rem 候选1/2：PATH 里的 py 启动器和 python（必须真实能跑，防止商店占位stub和被策略拦截的）
call :try_interpreter py -3
if defined PYCMD goto got_py
call :try_interpreter python
if defined PYCMD goto got_py

rem 候选3：常见安装路径逐个实测
call :try_path "C://Program Files//Python313//python.exe"
call :try_path "C://Program Files//Python312//python.exe"
call :try_path "C://Program Files//Python311//python.exe"
call :try_path "C://Program Files//Python310//python.exe"
call :try_path "C://Program Files//Python314//python.exe"
call :try_path "%LOCALAPPDATA%\Programs\Python\Python313\python.exe"
call :try_path "%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
call :try_path "%LOCALAPPDATA%\Programs\Python\Python311\python.exe"
call :try_path "%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
call :try_path "C://Python313//python.exe"
call :try_path "C://Python312//python.exe"
call :try_path "C://Python311//python.exe"
call :try_path "C://Python310//python.exe"
if defined PYCMD goto got_py

echo [失败] 没有找到"能实际运行"的 Python。
echo.
echo 可能原因：
echo   1. 电脑没装 Python：请让 IT 安装 python.org 官方版本（勾选 pip 和 tcl/tk）
echo   2. Python 被公司策略拦截（AppLocker/软件限制策略）：
echo      需要管理员放行 python.exe，或让 IT 提供可用的 Python
echo.
echo 可以自己在 cmd 里输入 python --version 试试，把结果发给管理员排查
pause
exit /b 1

:got_py
echo [1/4] 找到可用解释器：%PYCMD%

rem 记录 pythonw 路径，给 启动界面.bat 用（无控制台窗口）
%PYCMD% -c "import sys,os;d=os.path.dirname(sys.executable);w=os.path.join(d,'pythonw.exe');print(w if os.path.exists(w) else sys.executable)" > "python_env.txt"
if errorlevel 1 goto pyw_fallback
for %%S in ("python_env.txt") do if %%~zS==0 goto pyw_fallback
goto write_ok

:pyw_fallback
>"python_env.txt" echo %PYCMD%

:write_ok
echo [2/4] 安装依赖 pywin32 / PyYAML 到用户目录（--user，无需管理员）...
%PYCMD% -m pip install --user -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --disable-pip-version-check
if not errorlevel 1 goto pip_ok
rem pip 可能缺失，先补一次再重试
%PYCMD% -m ensurepip --upgrade >nul 2>nul
%PYCMD% -m pip install --user -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --disable-pip-version-check
if errorlevel 1 goto fail_pip

:pip_ok
echo [3/4] 安装完成。
echo [4/4] 运行离线自检（不连真实 Outlook）...
chcp 65001 >nul
%PYCMD% smoke_test.py
set "TEST_RC=%errorlevel%"
chcp 936 >nul
if not "%TEST_RC%"=="0" goto fail_test

echo.
echo ============================================================
echo  部署完成！以后双击 启动界面.bat 打开图形界面
echo  如需卸载依赖：%PYCMD% -m pip uninstall -y pywin32 pyyaml
echo ============================================================
pause
exit /b 0

:fail_pip
echo [错误] 依赖安装失败：请检查公司网络（或把脚本里的清华镜像地址换成公司内网源）
pause
exit /b 1

:fail_test
echo [错误] 自检未通过，请把上面的输出发回来排查
pause
exit /b 1

:try_interpreter
if defined PYCMD goto :eof
%* -c "import sys" >nul 2>nul
if not errorlevel 1 set "PYCMD=%*"
goto :eof

:try_path
if defined PYCMD goto :eof
if not exist %1 goto :eof
%1 -c "import sys" >nul 2>nul
if not errorlevel 1 set "PYCMD=%~1"
goto :eof
