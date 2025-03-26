from datetime import datetime, timedelta
import random
import hashlib
import os
from typing import Optional, Tuple

from sqlalchemy.orm import Session
from jose import jwt
from fastapi import HTTPException, status

from app.models.auth import User, UserProfile, UserDevice, VerificationCode
from app.schemas.auth import (
    RegisterRequest, UserProfileCreate, UserDeviceCreate,
    UserResponse, TokenResponse
)
from app.core.config import settings
from app.core.security import verify_password, get_password_hash

class AuthService:
    @staticmethod
    def create_user(db: Session, register: RegisterRequest) -> User:
        # 验证验证码
        if not AuthService.verify_code(db, register.phone, register.code, 1):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="验证码无效"
            )
        
        # 检查手机号是否已注册
        if AuthService.get_user_by_phone(db, register.phone):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="手机号已注册"
            )
        
        # 创建用户
        db_user = User(
            phone=register.phone,
            password_hash=get_password_hash(register.password)
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        
        return db_user

    @staticmethod
    def verify_code(db: Session, phone: str, code: str, type: int) -> bool:
        """验证短信验证码"""
        verification = db.query(VerificationCode).filter(
            VerificationCode.phone == phone,
            VerificationCode.type == type,
            VerificationCode.is_used == False,
            VerificationCode.expire_time > datetime.utcnow()
        ).first()
        
        if not verification or verification.code != code:
            return False
        
        # 标记验证码为已使用
        verification.is_used = True
        db.commit()
        
        return True

    @staticmethod
    def create_verification_code(db: Session, phone: str, type: int) -> str:
        """生成并保存验证码"""
        # 生成6位随机验证码
        code = ''.join(random.choices('0123456789', k=6))
        
        # 保存验证码
        verification = VerificationCode(
            phone=phone,
            code=code,
            type=type,
            expire_time=datetime.utcnow() + timedelta(minutes=5)
        )
        db.add(verification)
        db.commit()
        
        # 发送短信验证码
        AuthService.send_sms(phone, code, type)
        
        return code
        
    @staticmethod
    def send_sms(phone: str, code: str, sms_type: int) -> bool:
        """发送短信验证码"""
        from app.core.sms_service import SMSService
        return SMSService.send_sms(phone, code, sms_type)

    @staticmethod
    def authenticate_user(db: Session, phone: str, password: str) -> Optional[User]:
        """通过密码验证用户"""
        user = AuthService.get_user_by_phone(db, phone)
        if not user or not verify_password(password, user.password_hash):
            return None
        return user

    @staticmethod
    def authenticate_user_by_code(db: Session, phone: str, code: str) -> Optional[User]:
        """通过验证码验证用户"""
        if not AuthService.verify_code(db, phone, code, 2):
            return None
        return AuthService.get_user_by_phone(db, phone)

    @staticmethod
    def get_user_by_phone(db: Session, phone: str) -> Optional[User]:
        return db.query(User).filter(User.phone == phone).first()

    @staticmethod
    def create_access_token(user_id: int) -> TokenResponse:
        """创建访问令牌"""
        expires_delta = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        expire = datetime.utcnow() + expires_delta
        
        to_encode = {
            "sub": str(user_id),
            "exp": expire
        }
        encoded_jwt = jwt.encode(
            to_encode,
            settings.SECRET_KEY,
            algorithm=settings.ALGORITHM
        )
        
        return TokenResponse(
            access_token=encoded_jwt,
            expires_in=int(expires_delta.total_seconds())
        )

    @staticmethod
    def update_user_profile(
        db: Session,
        user: User,
        profile_data: UserProfileCreate
    ) -> UserProfile:
        """更新用户资料"""
        if not user.profile:
            profile = UserProfile(**profile_data.dict(), user_id=user.id)
            db.add(profile)
        else:
            for key, value in profile_data.dict(exclude_unset=True).items():
                setattr(user.profile, key, value)
        
        db.commit()
        db.refresh(user)
        return user.profile

    @staticmethod
    def register_device(
        db: Session,
        user: User,
        device_data: UserDeviceCreate
    ) -> UserDevice:
        """注册用户设备"""
        device = db.query(UserDevice).filter(
            UserDevice.user_id == user.id,
            UserDevice.device_token == device_data.device_token
        ).first()
        
        if device:
            # 更新现有设备信息
            for key, value in device_data.dict(exclude_unset=True).items():
                setattr(device, key, value)
            device.last_active_time = datetime.utcnow()
        else:
            # 创建新设备记录
            device = UserDevice(
                **device_data.dict(),
                user_id=user.id,
                last_active_time=datetime.utcnow()
            )
            db.add(device)
        
        db.commit()
        db.refresh(device)
        return device

    @staticmethod
    def change_password(
        db: Session,
        user: User,
        old_password: str,
        new_password: str
    ) -> bool:
        """修改密码"""
        if not verify_password(old_password, user.password_hash):
            return False
        
        user.password_hash = get_password_hash(new_password)
        db.commit()
        return True

    @staticmethod
    def reset_password(
        db: Session,
        phone: str,
        code: str,
        new_password: str
    ) -> bool:
        """重置密码"""
        if not AuthService.verify_code(db, phone, code, 3):
            return False
        
        user = AuthService.get_user_by_phone(db, phone)
        if not user:
            return False
        
        user.password_hash = get_password_hash(new_password)
        db.commit()
        return True

    @staticmethod
    def change_phone(
        db: Session,
        user: User,
        new_phone: str,
        code: str
    ) -> bool:
        """修改手机号"""
        # 验证验证码
        if not AuthService.verify_code(db, new_phone, code, 4):
            return False
        
        # 检查新手机号是否已被使用
        if AuthService.get_user_by_phone(db, new_phone):
            return False
        
        user.phone = new_phone
        db.commit()
        return True
