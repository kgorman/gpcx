FROM ghost:latest

# Install PostgreSQL client
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Install the required Node.js PostgreSQL driver
RUN cd /var/lib/ghost && \
    su node -c "npm install --production pg"

# Ghost will listen on port 2368
EXPOSE 2368

# Start Ghost
CMD ["node", "current/index.js"]
