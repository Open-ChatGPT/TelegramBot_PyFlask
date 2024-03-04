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

def check_url_exists(group_id, url):
    try:
        with db_connection.cursor() as cursor:
            query = "SELECT EXISTS(SELECT 1 FROM db_chat WHERE groupid=%s AND url=%s)"
            cursor.execute(query, (group_id, url))
            result = cursor.fetchone()
            return result[0] == 1  # 返回布尔值，表示是否存在
    except mysql.connector.Error as err:
        print(f"Error checking URL existence: {err}")
        return False