# TelegramBot.py
from telegram import ForceReply, Update
from telegram.ext import CommandHandler, ContextTypes, MessageHandler, filters
import MySQL

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user = update.effective_user
    await update.message.reply_html(rf"嗨 {user.mention_html()}！", reply_markup=ForceReply(selective=True))
    MySQL.insert_command_usage(user.id, '/start')

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    await update.message.reply_text("帮助！")

async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    await update.message.reply_text(update.message.text)

def setup(application):
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))
