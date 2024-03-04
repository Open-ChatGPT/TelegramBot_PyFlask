# MySQL.py
import mysql.connector
import os

db_connection = mysql.connector.connect(
    host=os.getenv('MYSQL_HOST'),
    user=os.getenv('MYSQL_USER'),
    password=os.getenv('MYSQL_PASSWORD'),
    database=os.getenv('MYSQL_DATABASE')
)

def insert_group_message(group_id, group_name, user_id, user_name, message_text):
    try:
        with db_connection.cursor() as cursor:
            query = """
            INSERT INTO group_messages (group_id, group_name, user_id, user_name, message_text) 
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(query, (group_id, group_name, user_id, user_name, message_text))
        db_connection.commit()
    except mysql.connector.Error as err:
        print("Error inserting group message: {}".format(err))

# 检查特定群组中的URL是否存在
def check_url_exists(group_id, url):
    """检查URL是否已存在于特定群组中"""
    try:
        with db_connection.cursor() as cursor:
            query = "SELECT EXISTS(SELECT 1 FROM db_chat WHERE groupid=%s AND url=%s)"
            cursor.execute(query, (group_id, url))
            result = cursor.fetchone()
            return result[0] == 1  # 如果存在返回True，否则返回False
    except mysql.connector.Error as err:
        print(f"数据库查询错误: {err}")
        return False

# 获取群组中的所有URL
def get_group_urls(group_id):
    """获取特定群组中的所有URL"""
    try:
        with db_connection.cursor() as cursor:
            cursor.execute("SELECT url FROM db_chat WHERE groupid=%s", (group_id,))
            return [row[0] for row in cursor.fetchall()]  # 返回一个包含所有URL的列表
    except mysql.connector.Error as err:
        print(f"数据库查询错误: {err}")
        return []

# 向群组中添加新的URL
def add_group_url(group_id, url):
    """将新的URL添加到特定群组中"""
    try:
        with db_connection.cursor() as cursor:
            cursor.execute("INSERT INTO db_chat (groupid, url) VALUES (%s, %s)", (group_id, url))
            db_connection.commit()
    except mysql.connector.Error as err:
        print(f"添加URL时发生错误: {err}")

# 从群组中删除URL
def delete_group_url(group_id, url):
    """从特定群组中删除URL"""
    try:
        with db_connection.cursor() as cursor:
            cursor.execute("DELETE FROM db_chat WHERE groupid=%s AND url=%s", (group_id, url))
            db_connection.commit()
    except mysql.connector.Error as err:
        print(f"删除URL时发生错误: {err}")n False