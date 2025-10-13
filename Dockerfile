FROM ghost:5.14.1

WORKDIR $GHOST_INSTALL
COPY . .

# Install PostgreSQL client and other utilities
RUN apt-get update && \
    apt-get install -y postgresql-client postgresql-client-common curl jq && \
    rm -rf /var/lib/apt/lists/*

# Install PostgreSQL drivers properly for Ghost
RUN npm install --no-save pg@8.7.1 knex@0.95.15

# Make sure the start script is executable
RUN chmod +x ./start.sh

# Set environment variable to ignore certificate validation
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# Ghost will run on port 2368
EXPOSE 2368

ENTRYPOINT []
CMD ["./start.sh"]
