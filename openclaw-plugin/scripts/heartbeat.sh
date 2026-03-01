#!/bin/bash
# Spark 节点心跳脚本
# 每小时自动运行，发送心跳到链上

SKILL_DIR="/usr/lib/node_modules/openclaw/skills/spark"
LOG_FILE="/var/log/spark-heartbeat.log"
PASSWORD_FILE="$HOME/.openclaw/spark_password"

# 获取密码
if [ -f "$PASSWORD_FILE" ]; then
  export SPARK_PASSWORD=$(cat "$PASSWORD_FILE")
else
  echo "[$(date)] 错误: 密码文件不存在 $PASSWORD_FILE" >> "$LOG_FILE"
  exit 1
fi

# 发送心跳
echo "[$(date)] 发送心跳..." >> "$LOG_FILE"
cd "$SKILL_DIR"
node src/index.js heartbeat >> "$LOG_FILE" 2>&1

# 检查结果
if [ $? -eq 0 ]; then
  echo "[$(date)] ✅ 心跳发送成功" >> "$LOG_FILE"
else
  echo "[$(date)] ❌ 心跳发送失败" >> "$LOG_FILE"
fi
