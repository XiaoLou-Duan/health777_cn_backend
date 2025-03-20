"""
日志中间件 - 提供请求日志记录功能
"""
from fastapi import Request
from fastapi.responses import JSONResponse
import time
from app.utils.logger import app_logger, log_request


async def logging_middleware(request: Request, call_next):
    """
    记录所有HTTP请求的中间件

    参数:
        request: FastAPI请求对象
        call_next: 下一个要调用的中间件或路由处理函数

    返回:
        response: FastAPI响应对象
    """
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
