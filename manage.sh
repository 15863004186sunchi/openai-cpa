#!/bin/bash

# Docker Management Script for openai-cpa

# 检测 docker-compose 命令 (兼容旧版和新版 docker compose)
if command -v docker-compose &> /dev/null; then
    DOCKER_CMD="docker-compose"
else
    DOCKER_CMD="docker compose"
fi

case "$1" in
  start)
    # 处理模式切换参数 (1: start, 2: mode_key)
    if [ "$2" == "gmail" ]; then
      echo "Switching to Gmail Alias mode..."
      sed -i 's/email_api_mode: .*/email_api_mode: "gmail_alias"/' config.yaml
    elif [ "$2" == "outlook" ]; then
      echo "Switching to Outlook File mode..."
      sed -i 's/email_api_mode: .*/email_api_mode: "outlook_file"/' config.yaml
    fi

    echo "Starting openai-cpa container via $DOCKER_CMD..."
    # 确保必要的数据文件存在防止被创建为目录
    touch accounts.txt
    touch outlook_used.txt
    $DOCKER_CMD up -d
    ;;
  stop)
    echo "Stopping openai-cpa container..."
    $DOCKER_CMD down
    ;;
  restart)
    echo "Restarting openai-cpa container..."
    $DOCKER_CMD restart
    ;;
  status)
    echo "Container status:"
    $DOCKER_CMD ps
    ;;
  logs)
    echo "Showing logs (Ctrl+C to exit):"
    $DOCKER_CMD logs -f
    ;;
  *)
    echo "Usage: $0 {start [gmail|outlook]|stop|restart|status|logs}"
    exit 1
esac
