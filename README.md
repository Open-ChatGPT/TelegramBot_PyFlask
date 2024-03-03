# Telegram Bot with Flask API

这个项目演示了如何创建一个Telegram机器人，该机器人集成了Flask作为Web服务器，并且可以与MySQL数据库交互。它可以处理基本的Telegram命令、回显消息，并通过Flask处理HTTP请求。

## 功能

- **响应Telegram命令**：机器人能够识别和响应预定义的命令。
- **回显用户消息**：用户发送的任何消息都会被机器人回显。
- **接收HTTP请求**：Flask应用接收并处理来自Web的HTTP请求。
- **记录数据到MySQL数据库**：机器人的活动和收到的数据可以存储到MySQL数据库中。

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

安装Python必要依赖：

```bash
pip install -r requirements.txt
```

### 配置环境变量

复制`.env.example`文件为`.env`，并填入适当的值：

```bash
cp .env.example .env
```

编辑`.env`文件，设置Telegram机器人的Token和数据库配置：

```
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

## 使用说明

- 发送`/start`或`/help`命令给Telegram机器人以测试基本功能。
- 发送任意文本消息给机器人，它将会回显消息。
- 访问`http://localhost:5000/`以测试Flask应用的根路径。
- 发送POST请求到`http://localhost:5000/webhook`以测试Webhook接收。

## 项目目录结构

```
TelegramBot_PyFlask/
│
├── main.py - 主程序入口，负责初始化和启动Telegram机器人和Flask应用。
│
├── TelegramBot.py - 定义了Telegram机器人的行为和命令处理。
│
├── MySQL.py - 处理数据库连接和操作的模块。
│
├── Api.py - 定义了Flask应用的路由和视图函数。
│
├── .env - 存储环境变量，如数据库配置和Telegram机器人的Token。
│
└── requirements.txt - 列出了所有Python依赖项，用于项目的安装。
```

## 开发和贡献

欢迎贡献代码、报告Bug或提出新功能建议。请通过GitHub的Issues或Pull Requests参与。

## 联系方式

如有疑问或需要帮助，请通过[GitHub Issues](https://github.com/Open-ChatGPT/TelegramBot_PyFlask/issues)联系我。

## 许可证

该项目采用 [MIT 许可证](LICENSE)。更多信息请查看LICENSE文件。
