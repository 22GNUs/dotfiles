#!/bin/bash

# 1. 查找所有名为 CloudShell 的进程 (忽略大小写)
# 注意：图片中显示名称为 CloudShell，你提到的 ClaudeShell 可能是笔误，脚本会自动处理
PROCESS_NAME="CloudShell"
PIDS=$(pgrep -i "$PROCESS_NAME")

if [ -z "$PIDS" ]; then
    echo "未找到进程: $PROCESS_NAME"
    exit 1
fi

echo "找到以下进程 PID: $PIDS"

# 2. 遍历并设置策略
for PID in $PIDS; do
    echo "正在处理 PID: $PID ..."
    
    # 【方案 A】限制到能效核心 (E-Cores) - 推荐用于“限制”使用率
    # -b 代表 Background 策略，在 M 芯片上会自动调度到 E-Cores
    sudo taskpolicy -b -p "$PID"
    
    # 【方案 B】如果你真的想“强制使用性能核心” (P-Cores)
    # 请取消下面这行的注释，并注释掉上面的方案 A
    # sudo taskpolicy -t -p "$PID"

    # 同时降低其调度优先级 (Nice 值)，让出更多 CPU 时间片
    sudo renice -n 20 -p "$PID"
done

echo "--------------------------------------"
echo "操作完成！这些进程现在运行在低功耗能效核心上，且优先级已调至最低。"
