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
        if kill -0 $PID 2>/dev/null; then
            echo "${GREEN}Python 脚本正在运行${NC}"
            return 0
        fi
    fi
    echo "${RED}Python 脚本未运行${NC}"
    return 1
}

# 检查 BotShell 系统变量是否设置
check_botshell_in_path() {
    if grep -q "$SCRIPT_DIR" "$HOME/.bashrc"; then
        echo "${GREEN}脚本变量已设置${NC}"
        return 0
    else
        echo "${RED}脚本变量未设置${NC}"
        return 1
    fi
}

# 检查 BotShell 是否设置为开机启动
check_botshell_autostart() {
    if (crontab -l | grep -q "$SCRIPT_PATH"); then
        echo "${GREEN}开机启动已设置${NC}"
        return 0
    else
        echo "${RED}开机启动未设置${NC}"
        return 1
    fi


# 切换 Python 脚本运行状态
toggle_python_script() {
    if check_python_running; then
        PID=$(cat "$PID_FILE")
        kill $PID && rm "$PID_FILE"
        echo -e "${GREEN}Python 脚本已停止。${NC}"
    else
        nohup python3 "$PYTHON_SCRIPT" > "$PYTHON_LOG" 2>&1 &
        echo $! > "$PID_FILE"
        echo -e "${GREEN}Python 脚本已启动。${NC}"
    fi
}

# 查看 Python 脚本日志
view_python_log() {
    if [ -f "$PYTHON_LOG" ]; then
        less "$PYTHON_LOG"
    else
        echo -e "${RED}日志文件不存在：$PYTHON_LOG${NC}"
    fi
}

# 切换脚本在系统变量和开机启动中的状态
toggle_settings() {
    local SHELL_RC="$HOME/.bashrc"
    local PATH_ENTRY="export PATH=\"\$PATH:$SCRIPT_DIR\""
    local CRONTAB_ENTRY="@reboot $SCRIPT_PATH"
    
    if check_botshell_in_path; then
        sed -i "\|$SCRIPT_DIR|d" "$SHELL_RC"
        echo -e "${GREEN}BotShell 系统变量已关闭。${NC}"
    else
        echo "$PATH_ENTRY" >> "$SHELL_RC"
        echo -e "${GREEN}BotShell 系统变量已开启。${NC}"
    fi
    
    if check_botshell_autostart; then
        (crontab -l | grep -v "$CRONTAB_ENTRY") | crontab -
        echo -e "${GREEN}BotShell 系统启动已关闭。${NC}"
    else
        (crontab -l 2>/dev/null; echo "$CRONTAB_ENTRY") | crontab -
        echo -e "${GREEN}BotShell 系统启动已开启。${NC}"
    fi
}

# 主菜单逻辑
while true; do
    clear
    echo "状态信息："
    Pystate=$(check_python_running)
    Shvariable=$(check_botshell_in_path)
    ShBootup=$(check_botshell_autostart)
    echo "- ${Shvariable} - ${ShBootup} - ${Pystate} -"
    echo "-------------------------"
    echo "请选择操作："
    if check_python_running; then
        echo "1) 停止 Python 脚本 ${GREEN_EMOJI}"
    else
        echo "1) 启动 Python 脚本 ${RED_EMOJI}"
    fi
    echo "2) 查看 Python 日志"
    if check_botshell_in_path && check_botshell_autostart; then
        echo "3) 关闭 BotShell 系统变量和系统启动 ${GREEN_EMOJI}"
    else
        echo "3) 启动 BotShell 系统变量和系统启动 ${RED_EMOJI}"
    fi
    echo "0) 退出"

    read -p "请选择操作： " option
    case $option in
        1) toggle_python_script ;;
        2) view_python_log ;;
        3) toggle_settings ;;
        0) break ;;
        *) echo -e "${RED}无效的选项 $option${NC}" ;;
    esac
done