FROM ghost:latest

# Install required packages
RUN apt-get update && \
    apt-get install -y postgresql-client curl jq && \
    rm -rf /var/lib/apt/lists/*

# Install the PostgreSQL Node.js driver globally
RUN npm install -g pg knex@"<1.0.0"

# Create a script to generate config and start Ghost
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Ghost will listen on port 2368
EXPOSE 2368

# Start Ghost with our custom script
CMD ["/start.sh"]
