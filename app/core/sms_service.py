from datetime import datetime, timedelta
import random

from alibabacloud_dysmsapi20170525.client import Client
from alibabacloud_dysmsapi20170525 import models as dysms_models
from alibabacloud_tea_openapi import models as open_api_models
from alibabacloud_tea_util.client import Client as UtilClient
from app.core.config import settings
from app.core.logger import get_logger
logger = get_logger("test.sms_service")

class SMSService:
    @staticmethod
    def send_sms(phone: str, code: str, sms_type: int) -> bool:
        """发送短信验证码"""

        if not all([settings.SMS_ACCESS_KEY_ID, settings.SMS_ACCESS_KEY_SECRET,
                   settings.SMS_SIGN_NAME, settings.SMS_TEMPLATE_CODE]):
            return False
  
        # 短信模板参数
        template_param = {"code": code}
        
        # 短信类型映射
        sms_type_map = {
            1: "注册验证",
            2: "登录验证",
            3: "修改密码",
            4: "修改手机号"
        }
        
        config = open_api_models.Config(
            access_key_id=settings.SMS_ACCESS_KEY_ID,
            access_key_secret=settings.SMS_ACCESS_KEY_SECRET,
            endpoint=settings.SMS_ENDPOINT,
            # region_id=settings.SMS_REGION_ID
        )
        
        try:
            client = Client(config)
            send_request = dysms_models.SendSmsRequest(
                phone_numbers=phone,
                sign_name=settings.SMS_SIGN_NAME,
                template_code=settings.SMS_TEMPLATE_CODE,
                template_param=str(template_param)
            )
            
            response = client.send_sms(send_request)
            logger.error(response)
            return response.body.code == "OK"
        except Exception as e:
            
            return False

    @staticmethod
    def generate_code() -> str:
        """生成6位随机验证码"""
        return ''.join(random.choices('0123456789', k=6))