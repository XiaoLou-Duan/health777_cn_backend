# 健康商品后端系统

这是一个使用Python和Flask构建的健康商品后端系统。

## 项目结构

```
healthGoodsBack/
├── app/                # 应用代码
├── tests/              # 测试代码
├── .env                # 环境变量配置
├── requirements.txt    # 项目依赖
└── README.md           # 项目说明
```

## 安装与设置

1. 创建并激活虚拟环境：

```bash
# 创建虚拟环境
python -m venv venv

# 激活虚拟环境 (Windows)
venv\Scripts\activate

# 激活虚拟环境 (Linux/Mac)
source venv/bin/activate
```

2. 安装依赖：

```bash
pip install -r requirements.txt
```

## 运行应用

```bash
# 设置环境变量
# Windows
set FLASK_APP=app
set FLASK_ENV=development

# Linux/Mac
export FLASK_APP=app
export FLASK_ENV=development

# 运行应用
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 运行测试

```bash
pytest
```
