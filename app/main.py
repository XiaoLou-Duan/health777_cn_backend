from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time
from app.utils.logger import app_logger, log_request

# 创建FastAPI应用实例
app = FastAPI(
    title="肌少症（肌护达）老年患者健康管理系统",
    description="为老年肌少症患者提供健康管理服务的API",
    version="0.1.0",
)

# 配置CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 在生产环境中应该设置为特定的域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 添加请求日志中间件
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """记录所有HTTP请求的中间件"""
    start_time = time.time()
    
    # 记录请求开始
    app_logger.info(f"开始处理请求: {request.method} {request.url}")
    
    try:
        # 处理请求
        response = await call_next(request)
        
        # 计算处理时间
        process_time = time.time() - start_time
        
        # 记录请求结束
        log_request(request, response)
        app_logger.info(f"请求处理完成: {request.method} {request.url} - 状态码: {response.status_code} - 耗时: {process_time:.4f}秒")
        
        return response
    except Exception as e:
        # 记录异常
        process_time = time.time() - start_time
        app_logger.error(f"请求处理异常: {request.method} {request.url} - 耗时: {process_time:.4f}秒 - 错误: {str(e)}")
        log_request(request, error=e)
        
        # 返回错误响应
        return JSONResponse(
            status_code=500,
            content={"detail": "服务器内部错误", "message": str(e)}
        )

# 导入各模块路由
# from app.api.auth import router as auth_router
# from app.api.nutrition import router as nutrition_router
# from app.api.exercise import router as exercise_router
# from app.api.social import router as social_router
# from app.api.medical import router as medical_router
# from app.api.reminders import router as reminders_router

# 注册路由
# app.include_router(auth_router, prefix="/api/auth", tags=["认证"])
# app.include_router(nutrition_router, prefix="/api/nutrition", tags=["营养管理"])
# app.include_router(exercise_router, prefix="/api/exercise", tags=["运动管理"])
# app.include_router(social_router, prefix="/api/social", tags=["社交功能"])
# app.include_router(medical_router, prefix="/api/medical", tags=["医患互动"])
# app.include_router(reminders_router, prefix="/api/reminders", tags=["提醒系统"])

@app.get("/")
async def root():
    """
    根路径，返回API基本信息
    """
    app_logger.info("访问根路径")
    return {
        "message": "欢迎使用肌少症【肌护达】老年患者健康管理系统API!",
        "version": "0.1.0",
        "status": "healthy"
    }

@app.get("/api/health")
async def health_check():
    """
    健康检查接口
    """
    app_logger.info("执行健康检查")
    return {
        "status": "ok",
        "timestamp": time.time()
    }