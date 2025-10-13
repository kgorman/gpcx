FROM ghost:5.14.1

WORKDIR $GHOST_INSTALL
COPY . .

# Install PostgreSQL client
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Add pg module for Ghost
RUN npm install pg

ENTRYPOINT []
CMD ["./start.sh"]
