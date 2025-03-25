"""
日志系统模块 - 提供统一的日志记录功能
"""
import os
import logging
import logging.handlers
from datetime import datetime
from pathlib import Path

# 日志级别映射
LOG_LEVELS = {
    "debug": logging.DEBUG,
    "info": logging.INFO,
    "warning": logging.WARNING,
    "error": logging.ERROR,
    "critical": logging.CRITICAL
}

# 默认日志格式
DEFAULT_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - [%(filename)s:%(lineno)d] - %(message)s"

# 日志存储目录
LOG_DIR = Path("logs")

def setup_logger(name, level="info", log_file=None, format_str=None, rotate=True, max_size_mb=10, backup_count=5):
    """
    设置并返回一个配置好的日志记录器

    参数:
        name (str): 日志记录器名称
        level (str): 日志级别 (debug, info, warning, error, critical)
        log_file (str, optional): 日志文件路径，如果为None则只输出到控制台
        format_str (str, optional): 日志格式，如果为None则使用默认格式
        rotate (bool): 是否启用日志轮转
        max_size_mb (int): 单个日志文件最大大小(MB)
        backup_count (int): 保留的日志文件数量

    返回:
        logging.Logger: 配置好的日志记录器
    """
    # 创建日志记录器
    logger = logging.getLogger(name)
    
    # 设置日志级别
    log_level = LOG_LEVELS.get(level.lower(), logging.INFO)
    logger.setLevel(log_level)
    
    # 如果已经有处理器，不再添加
    if logger.handlers:
        return logger
    
    # 设置日志格式
    formatter = logging.Formatter(format_str or DEFAULT_FORMAT)
    
    # 添加控制台处理器
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)
    
    # 如果指定了日志文件，添加文件处理器
    if log_file:
        # 确保日志目录存在
        log_path = Path(log_file)
        log_dir = log_path.parent
        os.makedirs(log_dir, exist_ok=True)
        
        if rotate:
            # 使用RotatingFileHandler进行日志轮转
            file_handler = logging.handlers.RotatingFileHandler(
                log_file,
                maxBytes=max_size_mb * 1024 * 1024,  # 转换为字节
                backupCount=backup_count,
                encoding='utf-8'
            )
        else:
            # 使用普通的FileHandler
            file_handler = logging.FileHandler(log_file, encoding='utf-8')
            
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)

    return logger


def get_logger(name, **kwargs):
    """
    获取一个配置好的日志记录器，如果不存在则创建

    参数:
        name (str): 日志记录器名称
        **kwargs: 传递给setup_logger的其他参数

    返回:
        logging.Logger: 配置好的日志记录器
    """
    # 确保日志目录存在
    os.makedirs(LOG_DIR, exist_ok=True)

    # 默认日志文件路径
    if 'log_file' not in kwargs:
        # 使用模块名作为日志文件名
        module_name = name.split('.')[-1]
        kwargs['log_file'] = LOG_DIR / f"{module_name}.log"

    return setup_logger(name, **kwargs)


# 创建应用默认日志记录器
app_logger = get_logger("health777.app", level="info")
api_logger = get_logger("health777.api", level="info")
db_logger = get_logger("health777.db", level="info")
auth_logger = get_logger("health777.auth", level="info")


def log_request(request, response=None, error=None):
    """
    记录HTTP请求和响应信息

    参数:
        request: FastAPI请求对象
        response: FastAPI响应对象(可选)
        error: 异常信息(可选)
    """
    # 获取请求信息
    client_ip = request.client.host if hasattr(request, 'client') and request.client else 'unknown'
    method = request.method
    url = request.url
    user_agent = request.headers.get('user-agent', 'unknown')

    # 基本日志信息
    log_data = {
        'timestamp': datetime.now().isoformat(),
        'client_ip': client_ip,
        'method': method,
        'url': str(url),
        'user_agent': user_agent,
    }

    # 如果有响应，添加响应信息
    if response:
        log_data['status_code'] = response.status_code

    # 如果有错误，添加错误信息
    if error:
        log_data['error'] = str(error)
        api_logger.error(f"请求错误: {log_data}")
    else:
        api_logger.info(f"请求信息: {log_data}")

    return log_data