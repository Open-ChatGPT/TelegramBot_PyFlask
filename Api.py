# Api.py
from flask import Flask, request, jsonify
from MySQL import query_db_by_group
#MySQL.py位于同一目录下，
#MySQL.py中名为query_db_by_group的函数
@app.route('/')
def home():
    return "Hello, World!"
    
@app.route('/webhook', methods=['POST'])
def webhook():
    data = request.json
    if not data or 'group' not in data:
        return jsonify({'error': 'Missing or invalid parameter: group'}), 400

    group = data['group']
    results = query_db_by_group(group)
    print(results)
    if not results:
        return jsonify({'message': 'Data is empty'}), 404
    return jsonify({'data': results}), 200
    
def setup_routes(app):
    app.add_url_rule('/', 'home', home)
    app.add_url_rule('/webhook', 'webhook', webhook, methods=['POST'])
