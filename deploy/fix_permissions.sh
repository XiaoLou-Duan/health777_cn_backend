#!/bin/bash

# 修复权限问题的脚本

APP_DIR="/usr/local/app/health777_cn_backend"
USER="appuser"
GROUP="appuser"

# 确保脚本以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "此脚本需要root权限运行"
    exit 1
fi

echo "==============================================="
echo "修复Health777 FastAPI服务权限问题"
echo "==============================================="

# 确保用户存在
echo "检查用户是否存在..."
if ! id "$USER" &>/dev/null; then
    echo "创建用户 $USER..."
    useradd -m -s /bin/bash "$USER"
    echo "✓ 用户已创建"
else
    echo "✓ 用户已存在"
fi

# 确保用户组存在
echo "检查用户组是否存在..."
if ! getent group "$GROUP" &>/dev/null; then
    echo "创建用户组 $GROUP..."
    groupadd "$GROUP"
    echo "✓ 用户组已创建"
else
    echo "✓ 用户组已存在"
fi

# 确保应用目录存在
echo "检查应用目录是否存在..."
if [ ! -d "$APP_DIR" ]; then
    echo "创建应用目录..."
    mkdir -p "$APP_DIR"
    echo "✓ 应用目录已创建"
else
    echo "✓ 应用目录已存在"
fi

# 修复目录权限
echo "修复目录权限..."
chown -R "$USER:$GROUP" "$APP_DIR"
chmod -R 755 "$APP_DIR"
echo "✓ 目录权限已修复"

# 确保deploy目录和日志文件存在
echo "创建deploy目录和日志文件..."
mkdir -p "$APP_DIR/deploy"
touch "$APP_DIR/deploy/deploy.log"
touch "$APP_DIR/deploy/webhook.log"
chown -R "$USER:$GROUP" "$APP_DIR/deploy"
chmod -R 755 "$APP_DIR/deploy"
echo "✓ deploy目录和日志文件已创建"

# 修复服务文件
echo "检查服务文件..."
if [ -f "/etc/systemd/system/health777_api.service" ]; then
    echo "修复FastAPI服务文件..."
    # 移除注释，避免解析问题
    sed -i 's/\s*#.*$//' /etc/systemd/system/health777_api.service
    echo "✓ FastAPI服务文件已修复"
else
    echo "✗ FastAPI服务文件不存在"
fi

if [ -f "/etc/systemd/system/webhook.service" ]; then
    echo "修复Webhook服务文件..."
    # 移除注释，避免解析问题
    sed -i 's/\s*#.*$//' /etc/systemd/system/webhook.service
    echo "✓ Webhook服务文件已修复"
else
    echo "✗ Webhook服务文件不存在"
fi

# 设置sudo权限
echo "设置sudo权限..."
echo "$USER ALL=(ALL) NOPASSWD: /bin/systemctl restart health777_api.service" > /etc/sudoers.d/health777
chmod 440 /etc/sudoers.d/health777
echo "✓ sudo权限已设置"

# 重新加载systemd配置
echo "重新加载systemd配置..."
systemctl daemon-reload
echo "✓ systemd配置已重新加载"

echo "==============================================="
echo "权限修复完成，请尝试重启服务:"
echo "sudo systemctl restart health777_api.service"
echo "sudo systemctl restart webhook.service"
echo "==============================================="
