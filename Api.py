# Api.py
from flask import Flask, request, jsonify
from MySQL import query_chat_data
#MySQL.py位于同一目录下，
#MySQL.py中名为query_db_by_group的函数
#@app.route('/')
def home():
    return "Hello, World!"
    
#@app.route('/webhook', methods=['POST'])
def webhook():
    data = request.json
    # 检查是否至少有一个参数存在
    if not data or ('group_id' not in data and 'name' not in data):
        return jsonify({'error': '必须附带group_id或者name字段值'}), 400

    # 根据接收到的参数选择查询类型
    if 'group_id' in data:
        query_value = data['group_id']
        query_type = 'group_id'
    else:
        query_value = data['name']
        query_type = 'name'
    
    # 调用 query_chat_data 执行数据库查询
    results = query_chat_data(query_value, query_type)
    print(results)
    if not results:
        return jsonify({'message': '数据为空'}), 404
    return jsonify({'data': results}), 200
    
def setup_routes(app):
    app.add_url_rule('/', 'home', home)
    app.add_url_rule('/webhook', 'webhook', webhook, methods=['POST'])
