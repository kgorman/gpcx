#!/bin/bash

# Health check for Ghost
# This script checks if the Ghost API is responding

# Variables
RETRY_COUNT=5
RETRY_DELAY=5
API_URL="http://localhost:2368/ghost/api/admin/site/"

# Check if Ghost is running
for i in $(seq 1 $RETRY_COUNT); do
  echo "Health check attempt $i of $RETRY_COUNT..."
  
  if curl -sf "$API_URL" > /dev/null; then
    echo "Ghost is healthy!"
    exit 0
  else
    echo "Ghost is not ready yet. Retrying in $RETRY_DELAY seconds..."
    sleep $RETRY_DELAY
  fi
done

echo "Ghost health check failed after $RETRY_COUNT attempts."
exit 1
