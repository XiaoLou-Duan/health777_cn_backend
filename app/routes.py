from flask import Blueprint, jsonify

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    return jsonify({"message": "欢迎使用健康商品后端系统"})

@main_bp.route('/api/health')
def health_check():
    return jsonify({"status": "healthy"})
