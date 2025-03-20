#!/bin/bash

# 检查服务状态和日志的脚本

APP_DIR="/usr/local/app/health777_cn_backend"
DEPLOY_LOG="$APP_DIR/deploy/deploy.log"
WEBHOOK_LOG="$APP_DIR/deploy/webhook.log"

echo "==============================================="
echo "Health777 FastAPI 服务状态检查"
echo "==============================================="

# 检查服务状态
echo "FastAPI 服务状态:"
systemctl status health777_api.service --no-pager | head -n 10

echo -e "\nWebhook 服务状态:"
systemctl status webhook.service --no-pager | head -n 10

# 显示最近的部署日志
if [ -f "$DEPLOY_LOG" ]; then
  echo -e "\n最近的部署日志 (最后10行):"
  tail -n 10 "$DEPLOY_LOG"
else
  echo -e "\n部署日志不存在: $DEPLOY_LOG"
fi

# 显示最近的webhook日志
if [ -f "$WEBHOOK_LOG" ]; then
  echo -e "\n最近的Webhook日志 (最后10行):"
  tail -n 10 "$WEBHOOK_LOG"
else
  echo -e "\nWebhook日志不存在: $WEBHOOK_LOG"
fi

# 检查端口监听状态
echo -e "\n端口监听状态:"
netstat -tulpn | grep -E ':(8000|9000)' || echo "没有找到相关端口监听"

# 检查Nginx配置
echo -e "\nNginx配置状态:"
nginx -t 2>&1

echo "==============================================="
