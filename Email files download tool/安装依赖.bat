@echo off
cd /d "%~dp0"
echo ============================================================
echo  邮件附件下载工具 - 首次部署：创建虚拟环境并安装依赖
echo ============================================================
echo.

where py >nul 2>nul
if %errorlevel%==0 (
    set "PY=py -3"
) else (
    where python >nul 2>nul
    if %errorlevel%==0 (
        set "PY=python"
    ) else (
        echo [错误] 未找到 Python，请先安装 Python 3.10+（勾选 tcl/tk 和 Add to PATH）
        pause
        exit /b 1
    )
)

echo [1/3] 创建虚拟环境 .venv ...
%PY% -m venv .venv
if %errorlevel% neq 0 (
    echo [错误] 创建虚拟环境失败
    pause
    exit /b 1
)

echo [2/3] 安装依赖（pywin32、PyYAML，使用清华镜像）...
.venv\Scripts\python.exe -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple --disable-pip-version-check
if %errorlevel% neq 0 (
    echo [错误] 依赖安装失败，请检查网络后重试
    pause
    exit /b 1
)

echo [3/3] 运行自检（不连真实 Outlook，验证代码链路）...
.venv\Scripts\python.exe smoke_test.py
if %errorlevel% neq 0 (
    echo [错误] 自检未通过，请把上面的输出发回来排查
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  部署完成！双击 启动界面.bat 打开图形界面
echo ============================================================
pause
