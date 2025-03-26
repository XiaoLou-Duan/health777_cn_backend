import pytest
from unittest.mock import patch, MagicMock

from app.core.sms_service import SMSService
from app.core.config import settings
from app.core.logger import app_logger

class TestSMSService:
    # @patch('app.core.sms_service.Client')
    # @patch('app.core.sms_service.dysms_models.SendSmsRequest')
    def test_send_sms_success(self):
        """测试短信发送成功"""
        # 调用方法
        result = SMSService.send_sms("18120227906", "2231", 1)
        app_logger.info(result)