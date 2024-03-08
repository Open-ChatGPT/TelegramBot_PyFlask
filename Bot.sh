#!/bin/bash
# 定义颜色和符号
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
RED_EMOJI='🔴'
GREEN_EMOJI='🟢'
# 直接定义颜色文本变量
GREEN_TEXT=$(echo -e "${GREEN}状态开启${NC}")
RED_TEXT=$(echo -e "${RED}状态关闭${NC}")

# 全局变量，用于保存最后一次操作的状态或消息
LAST_ACTION_STATUS=""

# 获取脚本的真实路径及目录
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PYTHON_SCRIPT="${SCRIPT_DIR}/python/main.py"
PYTHON_LOG="${SCRIPT_DIR}/python/script.log"
PID_FILE="${SCRIPT_DIR}/pidfile"
SHELL_VARIABLE="Bot"

# 检查 Python 脚本是否正在运行
is_python_script_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(<"$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
        	return 0
        else
        	return 1
        fi
    else
    	return 1
    fi
}

# 打印 Python 脚本运行状态文本
print_python_script_running_status() {
    if is_python_script_running; then
        echo "$GREEN_TEXT"
        return 0
    else
        echo "$RED_TEXT"
    	return 1
    fi
}

# 切换 Python 脚本运行状态
toggle_python_script() {
    if is_python_script_running; then
        PID=$(<"$PID_FILE")
        kill $PID && rm "$PID_FILE"
        LAST_ACTION_STATUS="${GREEN}Python 脚本已停止。${NC}"
    else
        nohup python3 "$PYTHON_SCRIPT" > "$PYTHON_LOG" 2>&1 &
        echo $! > "$PID_FILE"
        LAST_ACTION_STATUS="${GREEN}Python 脚本已启动。${NC}"
    fi
}

inspect_python_Bootup() {
    local crontab_entry="@reboot $PYTHON_SCRIPT"
    if crontab -l | grep -q "$PYTHON_SCRIPT"; then
        return 0
    else
        return 1
    fi
}

toggle_python_Bootup() {
    local crontab_entry="@reboot $PYTHON_SCRIPT"
    if inspect_python_Bootup; then
        (crontab -l | grep -v "$crontab_entry") | crontab -
        LAST_ACTION_STATUS="${LAST_ACTION_STATUS} ${GREEN}Python 开机启动已关闭。${NC}"
    else
        (crontab -l 2>/dev/null; echo "$crontab_entry") | crontab -
        LAST_ACTION_STATUS="${LAST_ACTION_STATUS} ${GREEN}Python 开机启动已开启。${NC}"
    fi
}
# 查看 Python 日志
view_python_log() {
    while true; do
        clear
        echo "日志文件内容："
        echo "-------------------------"
        if [ -f "$PYTHON_LOG" ]; then
            cat "$PYTHON_LOG"
        else
            echo -e "${RED}日志文件不存在：$PYTHON_LOG${NC}"
        fi
        echo "-------------------------"
        echo "按 0 退出查看日志"

        read -p "请选择操作： " log_option
        case $log_option in
            0) break ;;
            *) echo -e "${RED}无效的选项 $log_option${NC}" ;;
        esac
    done
}

# 检查 $HOME/bin 是否在 PATH 中，并返回状态字符串
path_in_bashrc_status() {
    if grep -qE '(\$HOME/bin|\$PATH)' "$HOME/.bashrc"; then
        echo "${GREEN}$HOME/bin 已在 PATH 中${NC}"
        return 0
    else
        echo "${RED}$HOME/bin 未在 PATH 中${NC}"
        return 1
    fi
}
# 检查符号链接和开机启动的状态，并返回状态字符串
symlink_and_startup_status() {
    local symlink_path="$HOME/bin/$SHELL_VARIABLE"
    local symlink_status="${RED_EMOJI}"
    local crontab_status="${RED_EMOJI}"

    if [ -L "$symlink_path" ]; then
        symlink_status="${GREEN_EMOJI}"
    fi

    if crontab -l | grep -q "$SCRIPT_PATH"; then
        crontab_status="${GREEN_EMOJI}"
    fi
    echo $symlink_status : $crontab_status 
}
# 切换符号链接和开机启动的设置
toggle_settings() {
    # 切换符号链接的存在状态
    local symlink_path="$HOME/bin/$SHELL_VARIABLE"
    if [ -L "$symlink_path" ]; then
        rm "$symlink_path"
        LAST_ACTION_STATUS="${GREEN}${SHELL_VARIABLE} 符号链接已移除。${NC}"
    else
        ln -s "$SCRIPT_PATH" "$symlink_path"
        LAST_ACTION_STATUS="${GREEN}${SHELL_VARIABLE}符号链接已创建。${NC}"
    fi
    
    # 切换开机启动设置
    local crontab_entry="@reboot $SCRIPT_PATH"
    if crontab -l | grep -q "$SCRIPT_PATH"; then
        (crontab -l | grep -v "$crontab_entry") | crontab -
        LAST_ACTION_STATUS="${LAST_ACTION_STATUS} ${GREEN}脚本开机启动已关闭。${NC}"
    else
        (crontab -l 2>/dev/null; echo "$crontab_entry") | crontab -
        LAST_ACTION_STATUS="${LAST_ACTION_STATUS} ${GREEN}脚本开机启动已开启。${NC}"
    fi
    
    # 检查并添加 $HOME/bin 到 PATH
    if ! path_in_bashrc_status; then
        echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
        LAST_ACTION_STATUS="${LAST_ACTION_STATUS} ${GREEN}已将 \$HOME/bin 添加到 PATH 中${NC}"
    fi
}
# 生成分隔线的函数
# 生成分隔线的函数，修正以正确生成分割线
generate_separator() {
    local total_width=$(($1 + $2 + $3)) # 计算总宽度，加上 | 和两边的空格
    printf '\33[5m \33[1m+' #开头
    printf '%*s' "7" | tr ' ' '-'
    printf '+' #开头
    printf '%*s' "17" | tr ' ' '-'
    printf '+' #开头
    printf '%*s' "9" | tr ' ' '-'
    printf '+\33[0m \n'
}

# 显示选项菜单的函数，修正以正确显示菜单和状态
show_menu() {
    clear
    local option_width=5
    local menu_item_width=20
    local status_width=10
    # 动态生成顶部分割线
    if [ ! -z "$LAST_ACTION_STATUS" ]; then
    generate_separator $option_width $menu_item_width $status_width
    echo -e " 操作状态: $LAST_ACTION_STATUS"
    fi
    generate_separator $option_width $menu_item_width $status_width
    # 打印表头
    printf " | %-${option_width}s | %-${menu_item_width}s| %-${status_width}s|\n" " 选项" "菜单选项" "状态"
    # 再次生成分割线
    generate_separator $option_width $menu_item_width $status_width
    # 菜单项：Python脚本运行状态
    local python_menu_state="$(print_python_script_running_status)"
    local python_status_state=$?
    local python_menu_item=$(echo -e "${GREEN}启动${NC} Python 脚本")
    local pytlog_menu_item=$(echo -e "${GREEN}查看${NC} Python 日志")
	if [ $python_status_state -eq 0 ]; then
    	python_menu_item=$(echo -e "${RED}关闭${NC} Python 脚本")
    	pytlog_menu_item=$(echo -e "${RED}查看${NC} Python 日志")
	fi
    printf " | %-${option_width}s | %-${menu_item_width}s| %-${status_width}s|\n" "  1" "$python_menu_item" "$python_menu_state"
    generate_separator $option_width $menu_item_width $status_width
    # 菜单项：查看Python日志
    printf " | %-${option_width}s | %-${menu_item_width}s| %-${status_width}s|\n" "  2" "$pytlog_menu_item" "${python_menu_state}"
    # 菜单项：符号链接和开机启动状态
    generate_separator $option_width $menu_item_width $status_width
    local botshl_status="$(symlink_and_startup_status)"
    printf " | %-${option_width}s | %-${menu_item_width}s| %-${status_width}s|\n" "  3" "切换 BotShl 状态" "${botshl_status} "
# 以下是根据 Python 开机启动状态调整的菜单显示逻辑
	inspect_python_Bootup
	local python_bootup_status=$?
    local bootup_menu_item=$(echo -e "${GREEN}开启${NC} Py脚本 自启")
    local bootup_menu_state="${RED_TEXT}"
	if [ $python_bootup_status -eq 0 ]; then
    	bootup_menu_item=$(echo -e "${RED}关闭${NC} Py脚本 自启")
        bootup_menu_state="${GREEN_TEXT}"
	fi
    generate_separator $option_width $menu_item_width $status_width
    printf " | %-${option_width}s | %-${menu_item_width}s| %-${status_width}s|\n" "  4" "$bootup_menu_item" "$bootup_menu_state"
    generate_separator $option_width $menu_item_width $status_width
    # 退出选项
    printf " | %-${option_width}s | %-${menu_item_width}s| %-${status_width}s|\n" "  Q" "退出 BotShl 脚本" "输入命令"
    # 结束分割线
    generate_separator $option_width $menu_item_width $status_width
}
# 主菜单逻辑调整
while true; do
    show_menu
    read -p "请选择操作： " option
    case $option in
        1) 
            toggle_python_script
            ;;
        2) 
            view_python_log
            ;;
        3) 
            toggle_settings # 正确调用切换设置的函数
            ;;
        4)
        	toggle_python_Bootup
            ;;
        0)
        	break
            ;;
        q) 
            break
            ;;
        Q)
        	break
            ;;
        *) 
            echo -e "${RED}无效的选项 $option${NC}" 
            ;;
    esac
done