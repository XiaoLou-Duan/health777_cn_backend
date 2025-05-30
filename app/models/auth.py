from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, DECIMAL, Text, ForeignKey, Boolean
from sqlalchemy.orm import relationship

from app.db.base_class import Base

class User(Base):
    """用户表"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), unique=True, index=True, nullable=False, comment="手机号")
    password_hash = Column(String(128), nullable=True, comment="密码哈希")
    is_active = Column(Boolean, default=True, comment="是否激活")
    is_superuser = Column(Boolean, default=False, comment="是否是超级管理员")
    register_time = Column(DateTime, default=datetime.utcnow, comment="注册时间")
    last_login_time = Column(DateTime, nullable=True, comment="最后登录时间")
    
    # 关联
    profile = relationship("UserProfile", back_populates="user", uselist=False)
    devices = relationship("UserDevice", back_populates="user")
    
    def __repr__(self):
        return f"<User {self.phone}>"

class UserProfile(Base):
    """用户资料表"""
    __tablename__ = "user_profiles"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    name = Column(String(50), nullable=True, comment="姓名")
    gender = Column(String(10), nullable=True, comment="性别")
    birth_date = Column(DateTime, nullable=True, comment="出生日期")
    height = Column(Integer, nullable=True, comment="身高(cm)")
    weight = Column(Integer, nullable=True, comment="体重(kg)")
    avatar = Column(String(255), nullable=True, comment="头像URL")
    address = Column(String(255), nullable=True, comment="地址")
    medical_history = Column(Text, nullable=True, comment="病史")
    emergency_contact = Column(String(50), nullable=True, comment="紧急联系人")
    emergency_phone = Column(String(20), nullable=True, comment="紧急联系人电话")
    
    # 关联
    user = relationship("User", back_populates="profile")
    
    def __repr__(self):
        return f"<UserProfile {self.name if self.name else 'Unknown'}>"

class UserDevice(Base):
    """用户设备表"""
    __tablename__ = "user_devices"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    device_id = Column(String(100), nullable=False, comment="设备ID")
    device_type = Column(String(50), nullable=True, comment="设备类型")
    device_name = Column(String(100), nullable=True, comment="设备名称")
    push_token = Column(String(255), nullable=True, comment="推送令牌")
    is_active = Column(Boolean, default=True, comment="是否活跃")
    last_active_time = Column(DateTime, default=datetime.utcnow, comment="最后活跃时间")
    
    # 关联
    user = relationship("User", back_populates="devices")
    
    def __repr__(self):
        return f"<UserDevice {self.device_id}>"

class VerificationCode(Base):
    """验证码表"""
    __tablename__ = "verification_codes"
    
    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), nullable=False, comment="手机号")
    code = Column(String(10), nullable=False, comment="验证码")
    type = Column(String(20), nullable=False, comment="类型：register, login, reset_password, change_phone")
    create_time = Column(DateTime, default=datetime.utcnow, comment="创建时间")
    expire_time = Column(DateTime, nullable=False, comment="过期时间")
    is_used = Column(Boolean, default=False, comment="是否已使用")
    
    def __repr__(self):
        return f"<VerificationCode {self.phone}: {self.code}>"
