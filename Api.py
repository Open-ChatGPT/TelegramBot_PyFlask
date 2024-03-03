# Api.py
from flask import request

def home():
    return "Hello, World!"

def webhook():
    data = request.json
    print(data)  # 实际应用中应更安全地处理数据
    return "Webhook received!", 200

def setup_routes(app):
    app.add_url_rule('/', 'home', home)
    app.add_url_rule('/webhook', 'webhook', webhook, methods=['POST'])
