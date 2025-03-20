# Health777 FastAPI 自动部署指南

本文档提供了在Ubuntu服务器上设置Health777 FastAPI服务的自动部署系统的详细步骤。

## 部署架构

该部署方案包括以下组件：

1. **Systemd服务**：管理FastAPI应用的运行
2. **GitHub Webhook**：接收代码更新通知
3. **自动部署脚本**：拉取最新代码并重启服务

## 初始设置

### 1. 克隆代码库

```bash
git clone https://github.com/your-username/health777_cn_backend.git /path/to/health777_cn_backend
cd /path/to/health777_cn_backend
```

### 2. 创建虚拟环境并安装依赖

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. 配置Systemd服务

编辑`deploy/health777_api.service`文件，替换以下占位符：
- 用户名和用户组
- 应用目录路径

然后设置服务：

```bash
sudo cp deploy/health777_api.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable health777_api.service
sudo systemctl start health777_api.service
```

### 4. 设置Webhook服务

编辑`deploy/webhook.service`和`deploy/webhook.py`文件，替换以下占位符：
- 用户名和用户组
- 应用目录路径
- Webhook密钥

然后设置服务：

```bash
# 安装webhook服务所需的依赖
pip install fastapi uvicorn

# 设置webhook服务
sudo cp deploy/webhook.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable webhook.service
sudo systemctl start webhook.service
```

### 5. 配置GitHub Webhook

1. 在GitHub仓库中，转到 Settings > Webhooks > Add webhook
2. 设置Payload URL为：`http://your-server-ip:9000/webhook/github`
3. 设置Content type为：`application/json`
4. 设置Secret为您在webhook.service中配置的密钥
5. 选择"Just the push event"
6. 启用webhook

## 部署脚本

`deploy.sh`脚本会执行以下操作：
1. 拉取最新代码
2. 更新依赖
3. 运行数据库迁移（如果有）
4. 重启服务

您可以手动运行此脚本：

```bash
bash /path/to/health777_cn_backend/deploy/deploy.sh
```

## 检查部署状态

### 查看服务状态

```bash
sudo systemctl status health777_api.service
sudo systemctl status webhook.service
```

### 查看日志

```bash
# 应用日志
sudo journalctl -u health777_api.service

# Webhook日志
sudo journalctl -u webhook.service
cat /path/to/health777_cn_backend/deploy/webhook.log

# 部署日志
cat /path/to/health777_cn_backend/deploy/deploy.log
```

## 故障排除

如果自动部署失败，请检查以下内容：

1. 确保所有路径都已正确设置
2. 检查用户权限
3. 查看日志文件了解详细错误信息
4. 确保GitHub Webhook密钥正确配置

## 安全注意事项

1. 使用HTTPS而非HTTP来保护webhook通信
2. 限制webhook服务的IP访问
3. 定期更新webhook密钥
4. 确保服务运行在低权限用户下
