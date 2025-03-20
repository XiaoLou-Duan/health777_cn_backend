#!/bin/bash

# 故障排除脚本

echo "==============================================="
echo "Health777 FastAPI 服务故障排除"
echo "==============================================="

APP_DIR="/usr/local/app/health777_cn_backend"
USER="appuser"

# 检查目录是否存在
echo "检查应用目录..."
if [ -d "$APP_DIR" ]; then
  echo "✓ 应用目录存在: $APP_DIR"
  ls -la "$APP_DIR"
else
  echo "✗ 应用目录不存在: $APP_DIR"
  echo "请创建目录并克隆代码库"
  exit 1
fi

# 检查用户是否存在
echo -e "\n检查应用用户..."
if id "$USER" &>/dev/null; then
  echo "✓ 用户存在: $USER"
else
  echo "✗ 用户不存在: $USER"
  echo "请创建用户: useradd -m -s /bin/bash $USER"
  exit 1
fi

# 检查目录权限
echo -e "\n检查目录权限..."
OWNER=$(stat -c '%U' "$APP_DIR")
GROUP=$(stat -c '%G' "$APP_DIR")
echo "目录所有者: $OWNER:$GROUP"
if [ "$OWNER" != "$USER" ]; then
  echo "✗ 目录所有者不是 $USER"
  echo "请修复权限: chown -R $USER:$USER $APP_DIR"
fi

# 检查虚拟环境
echo -e "\n检查Python虚拟环境..."
if [ -d "$APP_DIR/venv" ]; then
  echo "✓ 虚拟环境目录存在"
  if [ -f "$APP_DIR/venv/bin/uvicorn" ]; then
    echo "✓ uvicorn已安装"
  else
    echo "✗ uvicorn未安装"
    echo "请安装依赖: su - $USER -c 'cd $APP_DIR && source venv/bin/activate && pip install -r requirements.txt'"
  fi
else
  echo "✗ 虚拟环境目录不存在"
  echo "请创建虚拟环境: su - $USER -c 'cd $APP_DIR && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt'"
fi

# 检查服务文件
echo -e "\n检查服务文件..."
if [ -f "/etc/systemd/system/health777_api.service" ]; then
  echo "✓ FastAPI服务文件存在"
  grep "User=" /etc/systemd/system/health777_api.service
  grep "WorkingDirectory=" /etc/systemd/system/health777_api.service
  grep "ExecStart=" /etc/systemd/system/health777_api.service
else
  echo "✗ FastAPI服务文件不存在"
fi

if [ -f "/etc/systemd/system/webhook.service" ]; then
  echo "✓ Webhook服务文件存在"
  grep "User=" /etc/systemd/system/webhook.service
  grep "WorkingDirectory=" /etc/systemd/system/webhook.service
  grep "ExecStart=" /etc/systemd/system/webhook.service
else
  echo "✗ Webhook服务文件不存在"
fi

# 检查deploy目录
echo -e "\n检查deploy目录..."
if [ -d "$APP_DIR/deploy" ]; then
  echo "✓ deploy目录存在"
  ls -la "$APP_DIR/deploy"
else
  echo "✗ deploy目录不存在"
  echo "请创建deploy目录: mkdir -p $APP_DIR/deploy"
fi

# 检查日志目录权限
echo -e "\n创建日志目录并设置权限..."
mkdir -p "$APP_DIR/deploy"
touch "$APP_DIR/deploy/deploy.log"
touch "$APP_DIR/deploy/webhook.log"
chown -R "$USER:$USER" "$APP_DIR/deploy"
chmod -R 755 "$APP_DIR/deploy"
echo "✓ 已创建日志文件并设置权限"

# 检查sudo权限
echo -e "\n检查sudo权限..."
if [ -f "/etc/sudoers.d/health777" ]; then
  echo "✓ sudo权限文件存在"
  cat /etc/sudoers.d/health777
else
  echo "✗ sudo权限文件不存在"
  echo "创建sudo权限文件..."
  echo "$USER ALL=(ALL) NOPASSWD: /bin/systemctl restart health777_api.service" > /etc/sudoers.d/health777
  chmod 440 /etc/sudoers.d/health777
  echo "✓ 已创建sudo权限文件"
fi

# 尝试手动启动服务
echo -e "\n尝试手动启动FastAPI服务..."
echo "以$USER用户身份运行uvicorn..."
su - "$USER" -c "cd $APP_DIR && source venv/bin/activate && uvicorn app.main:app --host 127.0.0.1 --port 8000 --workers 1" &
PID=$!
sleep 5
kill $PID

echo -e "\n修复完成后，请重启服务:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl restart health777_api.service"
echo "sudo systemctl restart webhook.service"
echo "==============================================="
