# MySQL.py
import mysql.connector
import os

db_connection = mysql.connector.connect(
    host=os.getenv('MYSQL_HOST'),
    user=os.getenv('MYSQL_USER'),
    password=os.getenv('MYSQL_PASSWORD'),
    database=os.getenv('MYSQL_DATABASE')
)

def insert_command_usage(user_id, command):
    cursor = db_connection.cursor()
    try:
        cursor.execute("INSERT INTO command_usage (user_id, command) VALUES (%s, %s)", (user_id, command))
        db_connection.commit()
    except mysql.connector.Error as err:
        print("Something went wrong: {}".format(err))
    finally:
        cursor.close()
