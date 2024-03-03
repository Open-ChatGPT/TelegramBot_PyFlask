# Telegram Bot with Flask API

这个项目演示了如何创建一个Telegram机器人，该机器人集成了Flask作为Web服务器，并且可以与MySQL数据库交互。它可以处理基本的Telegram命令、回显消息，并通过Flask处理HTTP请求。

## 功能

- 响应Telegram命令
- 回显用户消息
- 接收HTTP请求
- 记录数据到MySQL数据库

## 开始

以下指南将帮助你在本地机器上安装和运行项目，用于开发和测试目的。

### 先决条件

- Python 3.6+
- pip
- MySQL数据库

### 安装

首先，克隆仓库到本地机器：

```bash
git clone https://github.com/Open-ChatGPT/TelegramBot_PyFlask.git
cd TelegramBot_PyFlask
```
安装python必要依赖：

```bash
pip install -r requirements.txt
```

配置环境变量
```bash
cp .env.example .env
```
```bash
TELEGRAM_TOKEN=你的Telegram机器人Token
MYSQL_HOST=数据库主机
MYSQL_USER=数据库用户名
MYSQL_PASSWORD=数据库密码
MYSQL_DATABASE=数据库名
FLASK_PORT=5000
FLASK_DEBUG=True
```
### 运行应用

运行以下命令启动Telegram机器人和Flask Web服务器：
```bash
python main.py
```
### 使用说明

- 发送/start或/help命令给Telegram机器人以测试基本功能。
- 发送任意文本消息给机器人，它将会回显消息。
- 访问http://localhost:5000/以测试Flask应用的根路径。
- 发送POST请求到http://localhost:5000/webhook以测试Webhook接收。