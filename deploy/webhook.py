#!/usr/bin/env python3
"""
GitHub Webhook处理器，用于自动部署
当收到push事件时，自动执行部署脚本
"""
import hmac
import hashlib
import json
import os
import subprocess
from fastapi import FastAPI, Request, HTTPException, Header, Depends
from fastapi.responses import JSONResponse
import logging

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    filename='/usr/local/app/health777_cn_backend/deploy/webhook.log'  # 替换为实际路径
)
logger = logging.getLogger(__name__)

app = FastAPI()

# GitHub Webhook密钥，需要与GitHub上配置的一致
WEBHOOK_SECRET = os.environ.get("WEBHOOK_SECRET", "kfiwwneHdwieohrgtf15")  # 请替换为实际的密钥
DEPLOY_SCRIPT = "/usr/local/app/health777_cn_backend/deploy/deploy.sh"  # 替换为实际的脚本路径

def verify_signature(signature: str = Header(None, alias="X-Hub-Signature-256"), payload: bytes = None):
    """验证GitHub Webhook签名"""
    if not signature:
        raise HTTPException(status_code=403, detail="签名缺失")
    
    try:
        signature = signature.replace("sha256=", "")
        mac = hmac.new(WEBHOOK_SECRET.encode(), msg=payload, digestmod=hashlib.sha256)
        expected_signature = mac.hexdigest()
        if not hmac.compare_digest(signature, expected_signature):
            raise HTTPException(status_code=403, detail="签名验证失败")
    except Exception as e:
        logger.error(f"签名验证错误: {str(e)}")
        raise HTTPException(status_code=403, detail=f"签名验证错误: {str(e)}")

@app.post("/webhook/github")
async def github_webhook(request: Request, x_github_event: str = Header(None)):
    """处理GitHub Webhook请求"""
    payload = await request.body()
    
    # 验证签名
    verify_signature(signature=request.headers.get("X-Hub-Signature-256"), payload=payload)
    
    # 只处理push事件
    if x_github_event != "push":
        return JSONResponse(content={"message": f"事件已接收，但不处理 {x_github_event} 事件"})
    
    # 解析payload
    try:
        data = json.loads(payload)
        branch = data.get("ref", "").replace("refs/heads/", "")
        
        # 只处理main分支的push事件
        if branch != "main":
            return JSONResponse(content={"message": f"事件已接收，但只处理main分支，不处理 {branch} 分支"})
        
        # 执行部署脚本 - 增强执行方式
        logger.info(f"收到main分支push事件，开始部署")
        
        # 确保脚本有执行权限
        try:
            os.chmod(DEPLOY_SCRIPT, 0o755)
            logger.info(f"已设置脚本执行权限: {DEPLOY_SCRIPT}")
        except Exception as e:
            logger.warning(f"设置脚本权限失败: {str(e)}")
        
        # 使用完整路径执行bash并传入脚本
        try:
            # 使用subprocess.run而不是Popen，以便实时获取输出
            logger.info(f"执行脚本: {DEPLOY_SCRIPT}")
            result = subprocess.run(
                ['/bin/bash', DEPLOY_SCRIPT], 
                capture_output=True,
                text=True,
                check=False
            )
            
            # 记录执行结果
            logger.info(f"脚本执行返回码: {result.returncode}")
            if result.stdout:
                logger.info(f"脚本输出: {result.stdout}")
            if result.stderr:
                logger.error(f"脚本错误: {result.stderr}")
                
            if result.returncode != 0:
                logger.error(f"部署脚本执行失败，返回码: {result.returncode}")
                return JSONResponse(
                    content={"message": "部署已触发但可能失败", "error": result.stderr},
                    status_code=500
                )
                
            return JSONResponse(content={"message": "部署已成功触发", "status": "success"})
        except Exception as e:
            logger.error(f"执行部署脚本时出错: {str(e)}")
            raise HTTPException(status_code=500, detail=f"执行部署脚本时出错: {str(e)}")
    
    except Exception as e:
        logger.error(f"处理webhook时出错: {str(e)}")
        raise HTTPException(status_code=500, detail=f"处理webhook时出错: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=9000)  # 使用不同于主应用的端口
