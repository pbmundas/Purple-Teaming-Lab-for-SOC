#!/bin/bash
set -e

echo "Cleaning up Purple Teaming Lab..."
docker-compose down -v
docker system prune -f
rm -rf configs/

echo "Cleanup complete."
