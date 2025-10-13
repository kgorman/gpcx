#!/bin/bash
set -o errexit

# Copy the content directories if they don't exist
baseDir="$GHOST_INSTALL/content.orig"
for src in "$baseDir"/*/ "$baseDir"/themes/*; do
    src="${src%/}"
    target="$GHOST_CONTENT/${src#$baseDir/}"
    mkdir -p "$(dirname "$target")"
    if [ ! -e "$target" ]; then
        tar -cC "$(dirname "$src")" "$(basename "$src")" | tar -xC "$(dirname "$target")"
    fi
done

# Create config.production.json from environment variables
echo "Creating Ghost configuration..."

# Get database connection info from environment
cat > config.production.json << EOF
{
  "url": "${url:-http://localhost:2368}",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "postgres",
    "connection": {
      "host": "${database__connection__host}",
      "port": ${database__connection__port:-5432},
      "user": "${database__connection__user}",
      "password": "${database__connection__password}",
      "database": "${database__connection__database}",
      "ssl": {
        "rejectUnauthorized": false
      }
    }
  },
  "logging": {
    "level": "info",
    "transports": ["stdout"]
  },
  "paths": {
    "contentPath": "/var/lib/ghost/content"
  }
}
EOF

# Update the URL using the updateConfig.js script
node updateConfig.js

# Start Ghost
node current/index.js
