from flask import Flask

def create_app():
    app = Flask(__name__)
    
    # 从.env文件加载配置
    app.config.from_prefixed_env()
    
    # 注册蓝图
    from app.routes import main_bp
    app.register_blueprint(main_bp)
    
    return app
