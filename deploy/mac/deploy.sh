#!/bin/bash

# =============================================
# go-admin 一键部署脚本（Mac 版本）
# =============================================

set -e

APP_NAME="go-admin"
APP_DIR="/usr/local/go-admin"
CONF_DIR="$APP_DIR/config"
LOG_DIR="$APP_DIR/logs"
DB_NAME="go_admin"
DB_USER="go_admin"
DB_PASSWORD="go_admin_2024"
DB_PORT="3306"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}    go-admin 一键部署脚本（Mac）${NC}"
echo -e "${GREEN}=============================================${NC}"

echo -e "\n${YELLOW}[1/8] 检查系统环境...${NC}"
if ! command -v go &> /dev/null; then
    echo -e "${RED}错误: 未安装 Go 环境，请先安装 Go 1.18+${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Go 版本: $(go version)${NC}"

echo -e "\n${YELLOW}[2/8] 创建目录结构...${NC}"
mkdir -p $APP_DIR $CONF_DIR $LOG_DIR
echo -e "${GREEN}✓ 目录创建完成${NC}"

echo -e "\n${YELLOW}[3/8] 编译后端项目...${NC}"
cd $(dirname "$0")/../..
CGO_ENABLED=0 go build -o $APP_DIR/$APP_NAME main.go
echo -e "${GREEN}✓ 编译完成${NC}"

echo -e "\n${YELLOW}[4/8] 复制配置文件...${NC}"
cp config/settings.yml $CONF_DIR/
sed -i "" "s/password:.*/password: $DB_PASSWORD/g" $CONF_DIR/settings.yml
sed -i "" "s/database:.*/database: $DB_NAME/g" $CONF_DIR/settings.yml
echo -e "${GREEN}✓ 配置文件复制完成${NC}"

echo -e "\n${YELLOW}[5/8] 创建数据库和用户...${NC}"
mysql -u root -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
"
echo -e "${GREEN}✓ 数据库创建完成${NC}"

echo -e "\n${YELLOW}[6/8] 导入初始化数据...${NC}"
mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < config/init.sql
echo -e "${GREEN}✓ 数据导入完成${NC}"

echo -e "\n${YELLOW}[7/8] 创建启动脚本...${NC}"
cat > $APP_DIR/start.sh << EOF
#!/bin/bash
cd $APP_DIR
./$APP_NAME
EOF
chmod +x $APP_DIR/start.sh
echo -e "${GREEN}✓ 启动脚本创建完成${NC}"

echo -e "\n${YELLOW}[8/8] 启动服务...${NC}"
cd $APP_DIR
./$APP_NAME > $LOG_DIR/app.log 2>&1 &
echo $! > $LOG_DIR/app.pid
sleep 3
if ps -p $(cat $LOG_DIR/app.pid) > /dev/null; then
    echo -e "${GREEN}✓ 服务启动成功${NC}"
else
    echo -e "${RED}✗ 服务启动失败${NC}"
    cat $LOG_DIR/app.log
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
echo -e "  - 启动: cd $APP_DIR && ./$APP_NAME"
echo -e "  - 停止: kill $(cat $LOG_DIR/app.pid)"
echo -e "  - 重启: kill $(cat $LOG_DIR/app.pid) && cd $APP_DIR && ./$APP_NAME &"
