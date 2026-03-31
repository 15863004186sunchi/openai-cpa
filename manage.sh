#!/bin/bash

# Docker Management Script for openai-cpa

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

    echo "Starting openai-cpa container..."
    # 确保 accounts.txt 存在防止被创建为目录
    touch accounts.txt
    docker-compose up -d
    ;;
  stop)
    echo "Stopping openai-cpa container..."
    docker-compose down
    ;;
  restart)
    echo "Restarting openai-cpa container..."
    docker-compose restart
    ;;
  status)
    echo "Container status:"
    docker-compose ps
    ;;
  logs)
    echo "Showing logs (Ctrl+C to exit):"
    docker-compose logs -f
    ;;
  *)
    echo "Usage: $0 {start [gmail|outlook]|stop|restart|status|logs}"
    exit 1
esac
