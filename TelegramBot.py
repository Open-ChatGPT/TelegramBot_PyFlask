# TelegramBot.py

import logging
from telegram import Update, ForceReply, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, ContextTypes, MessageHandler, filters, CallbackQueryHandler
import MySQL  # 引用MySQL模块进行数据库操作

# 配置日志
logging.basicConfig(format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO)
logger = logging.getLogger(__name__)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """处理/start命令的函数，向用户发送欢迎信息"""
    user = update.effective_user
    await update.message.reply_html(f"嗨 {user.mention_html()}！", reply_markup=ForceReply(selective=True))

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """处理/help命令的函数，提供使用说明"""
    await update.message.reply_text("帮助信息：\n/start - 开始对话\n/help - 显示帮助信息\n/show_chats - 管理群组URL")

async def show_chats(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """展示机器人所在的聊天信息，并根据命令执行者是否为管理员展示不同的信息"""
    chat_id = update.effective_chat.id
    user_id = update.effective_user.id

    # 检查命令执行者是否为管理员
    try:
        admin_list = await context.bot.get_chat_administrators(chat_id)
        admin_user_ids = [admin.user.id for admin in admin_list]
        is_admin = user_id in admin_user_ids
    except Exception as e:
        await update.message.reply_text("获取管理员信息时发生错误。")
        logger.error(f"获取管理员信息错误: {e}")
        return

    if not is_admin:
        await update.message.reply_text("此命令仅限管理员使用。")
        return

    args = context.args
    if args:
        handle_url_logic(args[0], chat_id, update, context)  # 处理含URL的逻辑
    else:
        display_group_urls(chat_id, update)  # 展示群组URL列表

async def handle_url_logic(url, chat_id, update, context):
    """检查URL是否存在，并提供相应的操作按钮"""
    exists = MySQL.check_url_exists(chat_id, url)
    if exists:
        keyboard = [[InlineKeyboardButton("删除", callback_data=f"delete:{url}")]]
    else:
        keyboard = [[InlineKeyboardButton("添加", callback_data=f"add:{url}")]]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(f"URL: {url}", reply_markup=reply_markup)

async def display_group_urls(chat_id, update):
    """查询并显示群组中的所有URL"""
    urls = MySQL.get_group_urls(chat_id)
    reply_text = "群组中的URL列表：" + "\n".join(urls) if urls else "群组中没有记录的URL。"
    await update.message.reply_text(reply_text)

async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """处理按钮点击事件"""
    query = update.callback_query
    await query.answer()
    data = query.data
    chat_id = update.effective_chat.id

    # 添加或删除URL的逻辑（需要根据实际情况实现）

def setup(application: Application):
    """注册命令和消息处理器"""
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("show_chats", show_chats))
    application.add_handler(CallbackQueryHandler(button_handler))