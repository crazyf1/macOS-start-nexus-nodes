打开macOS终端程序或者ssh远程登录到macOS

1. 运行脚本
bash ./start_nexus_screen.sh

2. 查看运行中的节点
screen -ls | grep 'nexus_node_'
这个命令会列出所有名称中包含 nexus_node_ 的 screen 会话，每个会话都对应一个正在运行的节点。

3. 连接到特定节点的输出
screen -r nexus_node_12983925
连接后，你就能看到该节点的所有控制台输出。

4. 从 screen 会话分离
当你连接到一个 screen 会话后，如果你想让它继续在后台运行，但又想返回到主终端进行其他操作，只需按下：
Ctrl + A (同时按下)然后松开 A，再按下 D，你就会从 screen 会话中“分离”出来，回到原来的终端，而
Nexus 节点仍然在 screen 会话中持续运行。

通过这种方式，你可以更高效、更稳定地管理你的多个 Nexus 节点。
