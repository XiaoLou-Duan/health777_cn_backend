from datetime import datetime, date
from typing import Optional
from pydantic import BaseModel, Field, EmailStr, constr

# 用户认证相关Schema
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int

class PhoneLoginRequest(BaseModel):
    phone: constr(pattern=r'^1[3-9]\d{9}$')
    code: constr(min_length=4, max_length=6)

class PasswordLoginRequest(BaseModel):
    phone: constr(pattern=r'^1[3-9]\d{9}$')
    password: str = Field(..., min_length=6, max_length=20)

class RegisterRequest(BaseModel):
    phone: constr(pattern=r'^1[3-9]\d{9}$')
    code: constr(min_length=4, max_length=6)
    password: str = Field(..., min_length=6, max_length=20)

class SendSmsRequest(BaseModel):
    phone: constr(pattern=r'^1[3-9]\d{9}$')
    type: int = Field(..., ge=1, le=4)  # 1-注册, 2-登录, 3-修改密码, 4-修改手机号

class ChangePasswordRequest(BaseModel):
    old_password: str = Field(..., min_length=6, max_length=20)
    new_password: str = Field(..., min_length=6, max_length=20)

class ResetPasswordRequest(BaseModel):
    phone: constr(pattern=r'^1[3-9]\d{9}$')
    code: constr(min_length=4, max_length=6)
    new_password: str = Field(..., min_length=6, max_length=20)

class ChangePhoneRequest(BaseModel):
    new_phone: constr(pattern=r'^1[3-9]\d{9}$')
    code: constr(min_length=4, max_length=6)

# 用户信息相关Schema
class UserProfileBase(BaseModel):
    name: Optional[str] = None
    gender: Optional[int] = None
    birth_date: Optional[date] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    avatar_url: Optional[str] = None
    health_condition: Optional[str] = None

class UserProfileCreate(UserProfileBase):
    pass

class UserProfileUpdate(UserProfileBase):
    pass

class UserProfileResponse(UserProfileBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class UserResponse(BaseModel):
    id: int
    phone: str
    status: int
    last_login_time: Optional[datetime]
    created_at: datetime
    profile: Optional[UserProfileResponse]

    class Config:
        from_attributes = True

# 设备相关Schema
class UserDeviceCreate(BaseModel):
    device_token: str
    device_type: str = Field(..., pattern='^(ios|android)$')
    device_model: Optional[str] = None

class UserDeviceResponse(UserDeviceCreate):
    id: int
    user_id: int
    last_active_time: Optional[datetime]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
