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

# 设置命令和初始化Telegram机器人
def setup(application):
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_command))
    
    application.add_handler(CommandHandler("show_chats", show_chats))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))
