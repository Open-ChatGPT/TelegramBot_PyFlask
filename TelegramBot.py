# TelegramBot.py
import logging
from telegram import ForceReply, Update, BotCommand
from telegram.ext import Application, CommandHandler, ContextTypes, MessageHandler, filters
import MySQL #引用MySQL文件

# 启用日志记录
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO
)
logger = logging.getLogger(__name__)


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user = update.effective_user
    await update.message.reply_html(rf"嗨 {user.mention_html()}！", reply_markup=ForceReply(selective=True))
    MySQL.insert_command_usage(user.id, '/start')

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    await update.message.reply_text("帮助！")

async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    await update.message.reply_text(update.message.text)

# 新增的show_chats功能
async def show_chats(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """展示机器人所在的聊天，并检查命令执行者在群聊中是否为管理员，输出本群对话ID"""
    chat_type = update.effective_chat.type
    if chat_type in ['group', 'supergroup']:
        admin_list = await context.bot.get_chat_administrators(update.effective_chat.id)
        admin_user_ids = [admin.user.id for admin in admin_list]
        if update.effective_user.id in admin_user_ids:
            text = f"本群对话ID: {update.effective_chat.id}"
        else:
            text = "此命令仅供群管理员操作。"
    else:
        text = "此命令仅供群聊支持。"
    await update.effective_message.reply_text(text)
    
# 设置命令和初始化Telegram机器人
def setup_commands(application: Application):
#def setup(application):
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("show_chats", show_chats))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))
    
def setup(application: Application):
    setup_commands(application)
