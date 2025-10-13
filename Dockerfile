FROM ghost:latest

# Add required timezone data
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV NODE_ENV=production
ENV url=http://localhost:2368
ENV database__client=postgres
# Explicitly set the port to 2368
ENV port=2368
# Fallback database variables in traditional format
ENV DATABASE_CLIENT=postgres

# Install PostgreSQL client and Node.js pg module
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/* && \
    cd /var/lib/ghost && \
    npm install pg --save

# Copy health check script only (we'll use env vars instead of config.production.json)
COPY health-check.sh /var/lib/ghost/health-check.sh

# Ensure health check script is executable
RUN chmod +x /var/lib/ghost/health-check.sh

# Create logs directory to avoid warnings
RUN mkdir -p /var/lib/ghost/content/logs

# Set the working directory
WORKDIR /var/lib/ghost

# Expose Ghost port
EXPOSE 2368

# Copy initialization script
COPY init.sh /var/lib/ghost/init.sh

# Start Ghost using the initialization script
CMD ["/bin/bash", "/var/lib/ghost/init.sh"]
