# main.py
from flask import Flask
from telegram.ext import Application
from dotenv import load_dotenv
import threading
import os
import TelegramBot
import Api

# 加载环境变量
load_dotenv()

app = Flask(__name__)

if __name__ == "__main__":
    # 设置和启动Flask应用
    Api.setup_routes(app)
    threading.Thread(target=lambda: app.run(port=int(os.getenv('FLASK_PORT', 5000)), debug=os.getenv('FLASK_DEBUG', 'False') == 'True'), daemon=True).start()

    # 设置和启动Telegram机器人
    application = Application.builder().token(os.getenv('TELEGRAM_TOKEN')).build()
    TelegramBot.setup(application)
    application.run_polling()