#!/bin/bash
# 定义颜色和符号
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
GREEN_TEXT="状态:${GREEN}开启${NC}"
RED_TEXT="状态:${RED}关闭${NC}"

LAST_ACTION_STATUS=""
MENU_Tab="\t+----+------+--------+------+-----------+"
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
PYTHON_SCRIPT="${SCRIPT_DIR}/python/main.py"
PYTHON_LOG="${SCRIPT_DIR}/python/script.log"
PID_FILE="${SCRIPT_DIR}/pidfile"
SHELL_VARIABLE="Bot"

# 检查 Python 脚本是否正在运行
check_python_script_running() {
    if [ -f "$PID_FILE" ]; then
        PID=$(<"$PID_FILE")
        if kill -0 $PID 2>/dev/null; then
            echo -e "${GREEN}启动${NC} | Python | 脚本 | ${RED_TEXT} |"
        	return 0
        fi
    fi
    echo -e "${RED}停止${NC} | Python | 脚本 | ${GREEN_TEXT} |"
    return 1
}
# 切换 Python 脚本运行状态
toggle_python_script() {
    if check_python_script_running > /dev/null; then
        PID=$(<"$PID_FILE")
        kill $PID && rm "$PID_FILE"
        LAST_ACTION_STATUS="${GREEN}停止运行:Python 脚本已停止。${NC}"
    else
        nohup python3 "$PYTHON_SCRIPT" > "$PYTHON_LOG" 2>&1 &
        echo $! > "$PID_FILE"
        LAST_ACTION_STATUS="${GREEN}启动脚本:Python 脚本已启动。${NC}"
    fi
}
# 检查Python 开机自启
inspect_python_Bootup() {
    crontab -l | grep -q "$PYTHON_SCRIPT" && echo -e "${GREEN}开启 | Python | 自启 | 状态:关闭${NC} |" || echo -e "${RED}关闭 | Python | 自启 | 状态:开启${NC} |"
}
toggle_python_Bootup() {
    if crontab -l | grep -q "$PYTHON_SCRIPT"; then
        crontab -l | grep -v "$PYTHON_SCRIPT" | crontab -
        LAST_ACTION_STATUS="Python 开机启动已关闭"
        echo $LAST_ACTION_STATUS
    else
        (crontab -l 2>/dev/null; echo "@reboot $PYTHON_SCRIPT") | crontab -
        LAST_ACTION_STATUS="Python 开机启动已开启"
        echo $LAST_ACTION_STATUS
    fi
}
# 检查Shell脚本变量
path_in_bashrc_status() {
    if grep -qE '(\$HOME/bin|\$PATH)' "$HOME/.bashrc"; then
        return 0
    else
        return 1
    fi
}
symlink_and_startup_status() {
    local symlink_path="$HOME/bin/$SHELL_VARIABLE"
    # 直接检查并赋值
    local symlink_status=$([ -L "$symlink_path" ] && echo "${GREEN}变量${NC}" || echo "${RED}变量${NC}")
    local crontab_status=$(crontab -l | grep -q "$SCRIPT_PATH" && echo "${GREEN}自启${NC}" || echo "${RED}自启${NC}")
    # 根据条件设置当前状态
    local Current_Status=$([[ "$symlink_status" == "${GREEN}变量${NC}" || "$crontab_status" == "${GREEN}自启${NC}" ]] && echo "${GREEN}开启${NC}" || echo "${RED}关闭${NC}")
    echo -e "${Current_Status} | BotShl | 状态 | ${symlink_status}:${crontab_status} |"
}
# 切换符号链接和开机启动的设置
toggle_settings() {
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
    fi
}
# 显示菜单和处理用户输入
function menu {
clear 
echo
echo -e "\t+---------------------------------------+"
echo -e "\t|********** BotShell-菜单选项 **********|"
echo -e "$MENU_Tab"
echo -e "\t| 1. | $(check_python_script_running)"
echo -e "$MENU_Tab"
echo -e "\t| 2. | $(inspect_python_Bootup)"
echo -e "$MENU_Tab"
echo -e "\t| 3. | 查看 | Python | 日志 | PythonLog |"
echo -e "$MENU_Tab"
echo -e "\t| 4. | $(symlink_and_startup_status)"
echo -e "$MENU_Tab"
echo -e "\t| 0. | 结束 | ExitMe | 菜单 | [Q][q][0] |"
echo -e "$MENU_Tab \n"
printf "\t操作响应 : $LAST_ACTION_STATUS \n"
printf "\t选择菜单 : "
read -n 1 option
echo
}
while [ 1 ]
do 
	menu
	case $option in
    1)
    	toggle_python_script
        ;;
    2)
    	toggle_python_Bootup
        ;;
    3) 
    	clear
        echo -e "\t${GREEN}********日志文件内容********${NC}"
        if [ -f "$PYTHON_LOG" ]; then
            cat "$PYTHON_LOG"
        else
            echo -e "\t${RED}日志文件不存在$PYTHON_LOG${NC}"
        fi
        echo -e "\n\n\t${GREEN}********按任意键返回菜单********${NC}"
        read -n 1
        ;;
    4)
    	toggle_settings ;;
    Q|q|0) 
  					echo -e "\t\t${GREEN}感谢使用！再见！${NC}"
    			break ;;
    *) echo -e "${RED}无效的选项 $option${NC}" ;;
    esac
done
#clear
