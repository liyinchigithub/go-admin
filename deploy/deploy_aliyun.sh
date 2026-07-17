#!/bin/bash

# =============================================
# go-admin 阿里云一键部署脚本
# 支持自动上传、安装依赖、配置服务
# =============================================

set -e

# 配置信息
APP_NAME="go-admin"
SERVER_USER="root"
SERVER_HOST=""
SERVER_PORT="22"
APP_DIR="/opt/go-admin"
DB_NAME="go_admin"
DB_USER="go_admin"
DB_PASSWORD="go_admin_2024"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}    go-admin 阿里云一键部署脚本${NC}"
echo -e "${GREEN}=============================================${NC}"

# 获取服务器信息
echo -e "\n${YELLOW}请输入阿里云服务器信息:${NC}"
read -p "服务器 IP 地址: " SERVER_HOST
read -p "SSH 端口 (默认 22): " SERVER_PORT_INPUT
if [ -n "$SERVER_PORT_INPUT" ]; then
    SERVER_PORT="$SERVER_PORT_INPUT"
fi

# 验证服务器连通性
echo -e "\n${YELLOW}[1/6] 验证服务器连通性...${NC}"
if ! ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST "echo 'Connected'" &> /dev/null; then
    echo -e "${RED}错误: 无法连接到服务器，请检查网络和SSH配置${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 服务器连接成功${NC}"

# 安装必要依赖
echo -e "\n${YELLOW}[2/6] 安装服务器依赖...${NC}"
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST << 'EOF'
    apt-get update && apt-get install -y mysql-server golang nginx
    systemctl start mysql
    systemctl enable mysql
EOF
echo -e "${GREEN}✓ 依赖安装完成${NC}"

# 创建目录结构
echo -e "\n${YELLOW}[3/6] 创建目录结构...${NC}"
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST "mkdir -p $APP_DIR/config"
echo -e "${GREEN}✓ 目录创建完成${NC}"

# 编译并上传项目
echo -e "\n${YELLOW}[4/6] 编译并上传项目...${NC}"
cd $(dirname "$0")/..
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /tmp/$APP_NAME main.go
scp -P $SERVER_PORT /tmp/$APP_NAME $SERVER_USER@$SERVER_HOST:$APP_DIR/
scp -P $SERVER_PORT config/settings.yml $SERVER_USER@$SERVER_HOST:$APP_DIR/config/
scp -P $SERVER_PORT config/init.sql $SERVER_USER@$SERVER_HOST:$APP_DIR/config/
echo -e "${GREEN}✓ 项目上传完成${NC}"

# 配置数据库和启动服务
echo -e "\n${YELLOW}[5/6] 配置数据库和启动服务...${NC}"
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST << EOF
    # 创建数据库
    mysql -u root -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
        GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
        FLUSH PRIVILEGES;
    "
    
    # 导入数据
    mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < $APP_DIR/config/init.sql
    
    # 更新配置
    sed -i "s/password:.*/password: $DB_PASSWORD/g" $APP_DIR/config/settings.yml
    sed -i "s/database:.*/database: $DB_NAME/g" $APP_DIR/config/settings.yml
    
    # 创建服务
    cat > /etc/systemd/system/go-admin.service << SERVICEEOF
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
SERVICEEOF
    
    systemctl daemon-reload
    systemctl enable go-admin
    systemctl start go-admin
EOF
echo -e "${GREEN}✓ 服务配置完成${NC}"

# 配置 Nginx 反向代理
echo -e "\n${YELLOW}[6/6] 配置 Nginx 反向代理...${NC}"
ssh -p $SERVER_PORT $SERVER_USER@$SERVER_HOST << EOF
    cat > /etc/nginx/sites-available/go-admin << NGINXEOF
server {
    listen 80;
    server_name $SERVER_HOST;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    location /api/ {
        proxy_pass http://localhost:8000/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
NGINXEOF
    
    ln -sf /etc/nginx/sites-available/go-admin /etc/nginx/sites-enabled/
    systemctl restart nginx
EOF
echo -e "${GREEN}✓ Nginx 配置完成${NC}"

echo -e "\n${GREEN}=============================================${NC}"
echo -e "${GREEN}         阿里云部署完成！${NC}"
echo -e "${GREEN}=============================================${NC}"
echo -e "服务地址: http://$SERVER_HOST"
echo -e "管理后台: http://$SERVER_HOST/admin"
echo -e "默认账号: admin"
echo -e "默认密码: 123456"
echo -e "服务命令:"
echo -e "  - 启动: systemctl start go-admin"
echo -e "  - 停止: systemctl stop go-admin"
echo -e "  - 重启: systemctl restart go-admin"
