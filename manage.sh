#!/bin/bash

# Docker Management Script for openai-cpa

case "$1" in
  start)
    echo "Starting openai-cpa container..."
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
    echo "Usage: $0 {start|stop|restart|status|logs}"
    exit 1
esac
