#!/bin/bash

# 定义颜色和符号
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
RED_EMOJI='🔴'
GREEN_EMOJI='🟢'

# 脚本和 Python 脚本的路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")"
PYTHON_SCRIPT="${SCRIPT_DIR}/python/main.py"
PYTHON_LOG="${SCRIPT_DIR}/python/script.log"
PID_FILE="${SCRIPT_DIR}/pidfile"

# 检查 Python 脚本是否正在运行
check_python_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if kill -0 $PID 2> /dev/null; then
            return 0
        fi
    fi
    return 1
}

# 启动 Python 脚本
start_python_script() {
    nohup python3 "$PYTHON_SCRIPT" > "$PYTHON_LOG" 2>&1 &
    echo $! > "$PID_FILE"
    echo -e "${GREEN}Python 脚本已启动。${NC}"
}

# 开机启动时检查并启动 Python 脚本
if ! check_python_running; then
    start_python_script
fi

# 切换 Python 脚本运行状态
toggle_python_script() {
    if check_python_running; then
        PID=$(cat "$PID_FILE")
        kill $PID && rm "$PID_FILE"
        echo -e "${GREEN}Python 脚本已停止。${NC}"
    else
        start_python_script
    fi
}

# 查看 Python 脚本日志
view_python_log() {
    [ -f "$PYTHON_LOG" ] && less "$PYTHON_LOG" || echo -e "${RED}日志文件不存在：$PYTHON_LOG${NC}"
}

# 主菜单逻辑
while true; do
    echo "-------------------------"
    echo "请选择操作："
    check_python_running && echo "1) 停止 Python 脚本 ${GREEN_EMOJI}" || echo "1) 启动 Python 脚本 ${RED_EMOJI}"
    echo "2) 查看 Python 日志"
    echo "3) 退出"
    
    read -p "请选择操作： " option
    case $option in
        1) toggle_python_script ;;
        2) view_python_log ;;
        3) break ;;
        *) echo -e "${RED}无效的选项 $option${NC}" ;;
    esac
done