from typing import Generator, Optional

from fastapi import Depends, HTTPException, status
from sqlalchemy.orm import Session
from jose import jwt

from app.core.config import settings
from app.core.security import oauth2_scheme, verify_token
from app.db.session import SessionLocal
from app.models.auth import User

def get_db() -> Generator:
    """获取数据库会话"""
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme)
) -> User:
    """获取当前登录用户"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="无效的认证凭证",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    user_id = verify_token(token)
    if not user_id:
        raise credentials_exception
    
    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user:
        raise credentials_exception
    
    if user.status == 0:  # 用户被禁用
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="用户已被禁用"
        )
    
    return user
