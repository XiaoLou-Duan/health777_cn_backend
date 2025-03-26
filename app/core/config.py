# 从 pydantic_settings 导入 BaseSettings，而不是从 pydantic 导入
from pydantic_settings import BaseSettings
from pydantic import EmailStr, field_validator
from typing import Optional  # 添加 Optional 导入

class Settings(BaseSettings):
    # API配置
    PROJECT_NAME: str = "肌护达健康管理系统"
    API_PREFIX: str = "/api"
    
    # 安全配置
    SECRET_KEY: str = "your-super-secret-key-here"  # 在生产环境中应该从环境变量获取
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7天
    
    # 数据库配置
    MYSQL_HOST: str = "localhost"
    MYSQL_PORT: str = "3306"
    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str = "your-db-password-here"
    MYSQL_DATABASE: str = "health777"
    
    # 短信服务配置
    SMS_ACCESS_KEY_ID: Optional[str] = None
    SMS_ACCESS_KEY_SECRET: Optional[str] = None
    SMS_SIGN_NAME: Optional[str] = None
    SMS_TEMPLATE_CODE: Optional[str] = None
    
    # 阿里云配置
    ALIYUN_ACCESS_KEY_ID: Optional[str] = None
    ALIYUN_ACCESS_KEY_SECRET: Optional[str] = None
    
    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
