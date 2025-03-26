from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime

from app.core.deps import get_db, get_current_user
from app.services.auth_service import AuthService
from app.schemas.auth import (
    RegisterRequest, PhoneLoginRequest, PasswordLoginRequest,
    SendSmsRequest, ChangePasswordRequest, ResetPasswordRequest,
    ChangePhoneRequest, UserProfileCreate, UserDeviceCreate,
    UserResponse, TokenResponse, UserProfileResponse, UserDeviceResponse
)
from app.models.auth import User

# 定义路由器时不要包含前缀，让主应用决定前缀
router = APIRouter()

@router.post("/register", response_model=TokenResponse)
def register(request: RegisterRequest, db: Session = Depends(get_db)):
    """用户注册"""
    user = AuthService.create_user(db, request)
    return AuthService.create_access_token(user.id)

@router.post("/login/phone", response_model=TokenResponse)
def login_by_phone(request: PhoneLoginRequest, db: Session = Depends(get_db)):
    """手机验证码登录"""
    user = AuthService.authenticate_user_by_code(db, request.phone, request.code)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="手机号或验证码错误"
        )
    
    # 更新最后登录时间
    user.last_login_time = datetime.utcnow()
    db.commit()
    
    return AuthService.create_access_token(user.id)

@router.post("/login/password", response_model=TokenResponse)
def login_by_password(request: PasswordLoginRequest, db: Session = Depends(get_db)):
    """密码登录"""
    user = AuthService.authenticate_user(db, request.phone, request.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="手机号或密码错误"
        )
    
    # 更新最后登录时间
    user.last_login_time = datetime.utcnow()
    db.commit()
    
    return AuthService.create_access_token(user.id)

@router.post("/sms/send")
def send_sms_code(request: SendSmsRequest, db: Session = Depends(get_db)):
    """发送短信验证码"""
    code = AuthService.create_verification_code(db, request.phone, request.type)
    # TODO: 实际发送短信的逻辑, 这里仅返回验证码
    return {"message": "验证码已发送"}


@router.post("/password/change")
def change_password(
    request: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """修改密码"""
    if not AuthService.change_password(db, current_user, request.old_password, request.new_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="原密码错误"
        )
    return {"message": "密码修改成功"}

@router.post("/password/reset")
def reset_password(request: ResetPasswordRequest, db: Session = Depends(get_db)):
    """重置密码"""
    if not AuthService.reset_password(db, request.phone, request.code, request.new_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="验证码无效或手机号不存在"
        )
    return {"message": "密码重置成功"}

@router.post("/phone/change")
def change_phone(
    request: ChangePhoneRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """修改手机号"""
    if not AuthService.change_phone(db, current_user, request.new_phone, request.code):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="验证码无效或手机号已被使用"
        )
    return {"message": "手机号修改成功"}

@router.get("/profile", response_model=UserProfileResponse)
def get_profile(current_user: User = Depends(get_current_user)):
    """获取用户资料"""
    return current_user.profile

@router.put("/profile", response_model=UserProfileResponse)
def update_profile(
    profile: UserProfileCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """更新用户资料"""
    return AuthService.update_user_profile(db, current_user, profile)

@router.post("/device", response_model=UserDeviceResponse)
def register_device(
    device: UserDeviceCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """注册设备"""
    return AuthService.register_device(db, current_user, device)
