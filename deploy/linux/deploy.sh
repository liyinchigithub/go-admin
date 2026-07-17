#!/bin/bash

# =============================================
# go-admin 一键部署脚本（Linux 版本）
# 适用于阿里云等 Linux 服务器
# =============================================

set -e

# 配置信息
APP_NAME="go-admin"
APP_DIR="/opt/go-admin"
CONF_DIR="$APP_DIR/config"
LOG_DIR="/var/log/go-admin"
DB_NAME="go_admin"
DB_USER="go_admin"
DB_PASSWORD="go_admin_2024"
DB_PORT="3306"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}    go-admin 一键部署脚本（Linux）${NC}"
echo -e "${GREEN}=============================================${NC}"

# 1. 检查系统环境
echo -e "\n${YELLOW}[1/8] 检查系统环境...${NC}"
if ! command -v go &> /dev/null; then
    echo -e "${RED}错误: 未安装 Go 环境，请先安装 Go 1.18+${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Go 版本: $(go version)${NC}"

if ! command -v mysql &> /dev/null; then
    echo -e "${RED}错误: 未安装 MySQL，请先安装 MySQL 5.7+${NC}"
    exit 1
fi
echo -e "${GREEN}✓ MySQL 已安装${NC}"

# 2. 创建目录结构
echo -e "\n${YELLOW}[2/8] 创建目录结构...${NC}"
mkdir -p $APP_DIR $CONF_DIR $LOG_DIR
echo -e "${GREEN}✓ 目录创建完成: $APP_DIR${NC}"

# 3. 编译后端项目
echo -e "\n${YELLOW}[3/8] 编译后端项目...${NC}"
cd $(dirname "$0")/..
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $APP_DIR/$APP_NAME main.go
echo -e "${GREEN}✓ 编译完成: $APP_DIR/$APP_NAME${NC}"

# 4. 复制配置文件
echo -e "\n${YELLOW}[4/8] 复制配置文件...${NC}"
cp config/settings.yml $CONF_DIR/
sed -i "s/password:.*/password: $DB_PASSWORD/g" $CONF_DIR/settings.yml
sed -i "s/database:.*/database: $DB_NAME/g" $CONF_DIR/settings.yml
echo -e "${GREEN}✓ 配置文件复制完成${NC}"

# 5. 创建数据库
echo -e "\n${YELLOW}[5/8] 创建数据库和用户...${NC}"
mysql -u root -p -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
"
echo -e "${GREEN}✓ 数据库创建完成${NC}"

# 6. 导入初始化数据
echo -e "\n${YELLOW}[6/8] 导入初始化数据...${NC}"
mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < config/init.sql
echo -e "${GREEN}✓ 数据导入完成${NC}"

# 7. 创建 systemd 服务
echo -e "\n${YELLOW}[7/8] 创建系统服务...${NC}"
cat > /etc/systemd/system/go-admin.service << EOF
[Unit]
Description=go-admin service
After=network.target mysqld.service

[Service]
Type=simple
ExecStart=$APP_DIR/$APP_NAME
WorkingDirectory=$APP_DIR
Restart=always
RestartSec=3
Environment=GIN_MODE=release

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable go-admin
echo -e "${GREEN}✓ 系统服务创建完成${NC}"

# 8. 启动服务
echo -e "\n${YELLOW}[8/8] 启动服务...${NC}"
systemctl start go-admin
sleep 3
if systemctl is-active --quiet go-admin; then
    echo -e "${GREEN}✓ 服务启动成功${NC}"
    echo -e "${GREEN}服务状态: $(systemctl status go-admin --no-pager | head -20)${NC}"
else
    echo -e "${RED}✗ 服务启动失败${NC}"
    systemctl status go-admin --no-pager
    exit 1
fi

echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}         部署完成！${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "服务地址: http://localhost:8000"
echo -e "管理后台: http://localhost:8000/admin"
echo -e "默认账号: admin"
echo -e "默认密码: 123456"
echo -e "日志位置: $LOG_DIR"
echo -e "服务命令:"
echo -e "  - 启动: systemctl start go-admin"
echo -e "  - 停止: systemctl stop go-admin"
echo -e "  - 重启: systemctl restart go-admin"
echo -e "  - 状态: systemctl status go-admin"
