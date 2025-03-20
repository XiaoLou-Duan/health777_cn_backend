#!/bin/bash

# 初始化脚本 - 在远程服务器首次设置时运行

# 设置变量
APP_DIR="/usr/local/app/health777_cn_backend"
GITHUB_REPO="https://github.com/XiaoLou-Duan/health777_cn_backend.git"
WEBHOOK_SECRET="kfiwwneHdwieohrgtf15"  # 请替换为实际的Webhook密钥
USER="appuser"  # 专门用于运行应用的用户
GROUP="appuser"  # 专门用于运行应用的用户组

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "此脚本需要root权限运行"
    exit 1
fi

# 创建专门的应用用户
echo "正在创建应用专用用户..."
id -u $USER &>/dev/null || useradd -m -s /bin/bash $USER
groupadd -f $GROUP
usermod -aG $GROUP $USER

# 更新系统并安装依赖
echo "正在更新系统并安装依赖..."
apt-get update
apt-get upgrade -y
apt-get install -y python3 python3-venv python3-pip git nginx

# 创建应用目录
echo "正在创建应用目录..."
mkdir -p "$APP_DIR"
chown -R "$USER:$GROUP" "$APP_DIR"

# 切换到应用用户
su - "$USER" << EOF
# 克隆代码库
echo "正在克隆代码库..."
git clone "$GITHUB_REPO" "$APP_DIR"

# 创建虚拟环境并安装依赖
echo "正在设置Python虚拟环境..."
cd "$APP_DIR"
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install fastapi uvicorn
EOF

# 替换配置文件中的占位符
echo "正在配置服务文件..."
cd "$APP_DIR/deploy"

# 替换服务文件中的占位符
sed -i "s|User=ubuntu|User=$USER|g" health777_api.service
sed -i "s|Group=ubuntu|Group=$GROUP|g" health777_api.service
sed -i "s|/path/to/health777_cn_backend|$APP_DIR|g" health777_api.service

sed -i "s|User=ubuntu|User=$USER|g" webhook.service
sed -i "s|Group=ubuntu|Group=$GROUP|g" webhook.service
sed -i "s|/path/to/health777_cn_backend|$APP_DIR|g" webhook.service
sed -i "s|your_webhook_secret|$WEBHOOK_SECRET|g" webhook.service

# 替换Python文件中的占位符
sed -i "s|/path/to/health777_cn_backend|$APP_DIR|g" webhook.py
sed -i "s|your_webhook_secret|$WEBHOOK_SECRET|g" webhook.py

# 替换部署脚本中的占位符
sed -i "s|/path/to/health777_cn_backend|$APP_DIR|g" deploy.sh

# 设置脚本权限
chmod +x deploy.sh

# 设置sudo权限，允许appuser无密码重启服务
echo "$USER ALL=(ALL) NOPASSWD: /bin/systemctl restart health777_api.service" > /etc/sudoers.d/health777
chmod 440 /etc/sudoers.d/health777

# 安装服务
echo "正在安装系统服务..."
cp health777_api.service /etc/systemd/system/
cp webhook.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable health777_api.service
systemctl enable webhook.service

# 启动服务
echo "正在启动服务..."
systemctl start health777_api.service
systemctl start webhook.service

# 配置Nginx（可选）
echo "正在配置Nginx..."
cat > /etc/nginx/sites-available/health777_api << NGINX_CONF
server {
    listen 80;
    server_name 8.148.65.62;  # 使用服务器IP

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /webhook/github {
        proxy_pass http://127.0.0.1:9000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
NGINX_CONF

ln -s /etc/nginx/sites-available/health777_api /etc/nginx/sites-enabled/
nginx -t && systemctl restart nginx

# 确保防火墙允许HTTP和Webhook端口
if command -v ufw &> /dev/null; then
    echo "配置防火墙规则..."
    ufw allow 80/tcp
    ufw allow 9000/tcp
    ufw allow 8000/tcp
fi

# 输出状态信息
echo "==============================================="
echo "安装完成！"
echo "FastAPI服务状态："
systemctl status health777_api.service --no-pager
echo "Webhook服务状态："
systemctl status webhook.service --no-pager
echo "==============================================="
echo "请在GitHub仓库中设置Webhook："
echo "URL: http://8.148.65.62:9000/webhook/github"
echo "Secret: $WEBHOOK_SECRET"
echo "Content type: application/json"
echo "Events: Just the push event"
echo "==============================================="
