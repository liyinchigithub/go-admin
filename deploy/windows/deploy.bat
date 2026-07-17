@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set APP_NAME=go-admin
set APP_DIR=C:\go-admin
set CONF_DIR=%APP_DIR%\config
set LOG_DIR=%APP_DIR%\logs
set DB_NAME=go_admin
set DB_USER=go_admin
set DB_PASSWORD=go_admin_2024
set DB_PORT=3306

echo.
echo =============================================
echo    go-admin 一键部署脚本（Windows）
echo =============================================
echo.

echo [1/8] 检查系统环境...
where go >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未安装 Go 环境，请先安装 Go 1.18+
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('go version') do set GO_VERSION=%%i
echo ✓ Go 版本: !GO_VERSION!

echo.
echo [2/8] 创建目录结构...
mkdir "%APP_DIR%" >nul 2>&1
mkdir "%CONF_DIR%" >nul 2>&1
mkdir "%LOG_DIR%" >nul 2>&1
echo ✓ 目录创建完成

echo.
echo [3/8] 编译后端项目...
cd /d "%~dp0\..\.."
set CGO_ENABLED=0
go build -o "%APP_DIR%\%APP_NAME%.exe" main.go
if %errorlevel% neq 0 (
    echo 错误: 编译失败
    pause
    exit /b 1
)
echo ✓ 编译完成

echo.
echo [4/8] 复制配置文件...
copy "config\settings.yml" "%CONF_DIR%\" >nul
powershell -Command "(Get-Content '%CONF_DIR%\settings.yml') -replace 'password:.*', 'password: %DB_PASSWORD%' | Set-Content '%CONF_DIR%\settings.yml'"
powershell -Command "(Get-Content '%CONF_DIR%\settings.yml') -replace 'database:.*', 'database: %DB_NAME%' | Set-Content '%CONF_DIR%\settings.yml'"
echo ✓ 配置文件复制完成

echo.
echo [5/8] 创建数据库和用户...
mysql -u root -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -e "CREATE USER IF NOT EXISTS '%DB_USER%'@'localhost' IDENTIFIED BY '%DB_PASSWORD%';"
mysql -u root -e "GRANT ALL PRIVILEGES ON %DB_NAME%.* TO '%DB_USER%'@'localhost'; FLUSH PRIVILEGES;"
echo ✓ 数据库创建完成

echo.
echo [6/8] 导入初始化数据...
mysql -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% < config\init.sql
echo ✓ 数据导入完成

echo.
echo [7/8] 创建启动脚本...
echo @echo off > "%APP_DIR%\start.bat"
echo cd /d "%APP_DIR%" >> "%APP_DIR%\start.bat"
echo %APP_NAME%.exe >> "%APP_DIR%\start.bat"
echo ✓ 启动脚本创建完成

echo.
echo [8/8] 启动服务...
cd /d "%APP_DIR%"
start "" "%APP_NAME%.exe"
timeout /t 3 /nobreak >nul
echo ✓ 服务启动成功

echo.
echo =============================================
echo         部署完成！
echo =============================================
echo 服务地址: http://localhost:8000
echo 管理后台: http://localhost:8000/admin
echo 默认账号: admin
echo 默认密码: 123456
echo 日志位置: %LOG_DIR%
echo 服务命令:
echo   - 启动: 双击 start.bat
echo   - 停止: 关闭命令窗口
pause
