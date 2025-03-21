#!/bin/bash

# 设置变量
APP_DIR="/usr/local/app/health777_cn_backend"  # 请替换为实际的应用目录路径
VENV_DIR="$APP_DIR/venv"
LOG_FILE="$APP_DIR/deploy/deploy.log"

# 添加常用的可执行文件路径
export PATH=$PATH:/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin

# 确保日志目录存在
mkdir -p "$(dirname "$LOG_FILE")"

# 记录部署时间
echo "===============================================" >> "$LOG_FILE"
echo "部署开始: $(date)" >> "$LOG_FILE"

# 输出当前环境信息以便调试
echo "当前用户: $(whoami)" >> "$LOG_FILE"
echo "PATH: $PATH" >> "$LOG_FILE"
echo "Git路径: $(which git 2>/dev/null || echo 'Git未找到')" >> "$LOG_FILE"

# 切换到应用目录
cd "$APP_DIR" || { echo "无法进入应用目录: $APP_DIR" >> "$LOG_FILE"; exit 1; }

# 拉取最新代码 (使用git的完整路径)
echo "正在拉取最新代码..." >> "$LOG_FILE"
/usr/bin/git pull origin main >> "$LOG_FILE" 2>&1 || { 
  echo "尝试使用不同的git路径..." >> "$LOG_FILE"
  # 尝试其他可能的git位置
  if [ -x "/usr/local/bin/git" ]; then
    /usr/local/bin/git pull origin main >> "$LOG_FILE" 2>&1
  else
    # 如果找不到git，使用which命令查找
    GIT_PATH=$(which git 2>/dev/null)
    if [ -n "$GIT_PATH" ]; then
      "$GIT_PATH" pull origin main >> "$LOG_FILE" 2>&1
    else
      echo "Git拉取失败，找不到git命令" >> "$LOG_FILE"
      exit 1
    fi
  fi
}

# 激活虚拟环境并更新依赖
echo "正在更新依赖..." >> "$LOG_FILE"
source "$VENV_DIR/bin/activate" || { echo "无法激活虚拟环境" >> "$LOG_FILE"; exit 1; }
pip install -r requirements.txt >> "$LOG_FILE" 2>&1 || { echo "依赖安装失败" >> "$LOG_FILE"; exit 1; }

# 运行数据库迁移(如果有)
if [ -d "$APP_DIR/alembic" ]; then
  echo "正在运行数据库迁移..." >> "$LOG_FILE"
  alembic upgrade head >> "$LOG_FILE" 2>&1 || { echo "数据库迁移失败" >> "$LOG_FILE"; exit 1; }
fi

# 重启服务
echo "正在重启服务..." >> "$LOG_FILE"
sudo systemctl restart health777_api.service >> "$LOG_FILE" 2>&1 || { echo "服务重启失败" >> "$LOG_FILE"; exit 1; }

# 检查服务状态
sleep 5
SERVICE_STATUS=$(systemctl is-active health777_api.service)
if [ "$SERVICE_STATUS" = "active" ]; then
  echo "部署成功，服务已重启并正常运行" >> "$LOG_FILE"
else
  echo "部署失败，服务未能正常启动" >> "$LOG_FILE"
  echo "服务状态: $SERVICE_STATUS" >> "$LOG_FILE"
  systemctl status health777_api.service >> "$LOG_FILE" 2>&1
  exit 1
fi

echo "部署完成: $(date)" >> "$LOG_FILE"
echo "===============================================" >> "$LOG_FILE"
