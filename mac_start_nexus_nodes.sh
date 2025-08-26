#!/usr/bin/env bash

# 运行脚本(先修改ID列表)
# 打开终端执行 bash mac_start_nexus_nodes.sh
# 查看运行中的节点
# 打开终端执行 screen -ls | grep 'nexus_node_'
# 连接到特定节点的输出
# 打开终端执行 screen -r nexus_node_12983925


# 配置路径和参数
# 主日志文件，记录脚本的启动信息
MAIN_LOG_FILE="nexus_startup.log" 
# Nexus 二进制文件的路径，根据当前用户动态获取
NEXUS_BIN="/Users/$(whoami)/.nexus/bin/nexus-network"
# 每个节点的最大线程数
THREADS=2 
# 启动每个节点之间的延迟时间，用于避免系统过载
SLEEP_DELAY=0.2 

# 您的节点 ID - 重要：请更新为您的实际节点 ID
IDS=(
  32983921
  33074322
  33077313
)

# 检查 nexus-network 是否存在且可执行
if [[ ! -x "$NEXUS_BIN" ]]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') 错误：$NEXUS_BIN 未找到或不可执行" | tee -a "$MAIN_LOG_FILE"
  exit 1
fi

# 检查 'screen' 命令是否可用
if ! command -v screen &> /dev/null; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') 错误：'screen' 命令未找到. 请安装 'screen' 或使用其他启动方式." | tee -a "$MAIN_LOG_FILE"
  exit 1
fi

# --- 节点启动循环 ---

for id in "${IDS[@]}"; do
  # 为每个节点定义一个 screen 会话名称
  SESSION_NAME="nexus_node_${id}"
  # 为每个节点定义一个独立的日志文件路径
  NODE_LOG_PATH="nexus_node_${id}.log" 

  echo "$(date '+%Y-%m-%d %H:%M:%S') 正在尝试在 screen 会话 '$SESSION_NAME' 中启动节点 ID $id..." | tee -a "$MAIN_LOG_FILE"

  # 如果存在同名的 screen 会话，则先杀死它（用于重新运行脚本时清理旧会话）
  screen -S "$SESSION_NAME" -X quit > /dev/null 2>&1

  # 在 screen 会话内部运行的命令
  # `exec` 会用 nexus-network 进程替换 shell，确保它是 screen 中的主进程
  # `--headless` 参数表示无头模式启动（可能在 Nexus 0.3.x+ 中可用，如果你的版本不支持，请移除此行或检查文档）
  RUN_COMMAND="exec '$NEXUS_BIN' start --node-id $id --headless --max-threads $THREADS >> \"$NODE_LOG_PATH\" 2>&1"

  # 启动一个新的分离的 screen 会话 (-d 表示分离，-m 表示即使不在终端也创建，-S 指定会话名称)
 screen -dmS "$SESSION_NAME" bash -c "$RUN_COMMAND"

  # 检查 screen 命令的退出状态
  if [[ $? -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') 警告：启动节点 ID $id 的 screen 会话失败." | tee -a "$MAIN_LOG_FILE"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S') 成功启动 screen 会话 '$SESSION_NAME'. 进程详情将写入 $NODE_LOG_PATH" | tee -a "$MAIN_LOG_FILE"
  fi
  sleep "$SLEEP_DELAY" # 短暂延迟以避免系统过载
done

echo "$(date '+%Y-%m-%d %H:%M:%S') 所有节点启动请求已发送. 您可以使用 'screen -ls' 查看会话，使用 'screen -r <session_name>' 重新连接。" | tee -a "$MAIN_LOG_FILE"

# --- screen 会话管理指南 ---
echo "" | tee -a "$MAIN_LOG_FILE"
echo "--- screen 会话管理指南 ---" | tee -a "$MAIN_LOG_FILE"
echo "查看所有 Nexus 节点会话: screen -ls | grep 'nexus_node_'" | tee -a "$MAIN_LOG_FILE"
echo "重新连接到某个节点 (例如 ID 12345678): screen -r nexus_node_12345678" | tee -a "$MAIN_LOG_FILE"
echo "在 screen 会话中，按 Ctrl+A 然后按 D 键可以分离会话 (返回主终端)." | tee -a "$MAIN_LOG_FILE"
echo "要杀死某个会话: screen -X -S nexus_node_12345678 quit" | tee -a "$MAIN_LOG_FILE"
echo "--------------------------" | tee -a "$MAIN_LOG_FILE"
