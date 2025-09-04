# Use a minimal Linux base image
FROM ubuntu:22.04

# Install required packages including OpenJDK 21 and cron
RUN apt-get update && \
    apt-get install -y openjdk-21-jdk cron && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME and PATH
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
RUN java -version

# Set working directory for server
WORKDIR /app

# Copy server folder and make run.sh executable
COPY server/ /app
CMD java -Xmx1024M -Xms1024M -jar server.jar nogui

# Copy backup script and make it executable
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Setup cron jobs for auto-backup
RUN echo "*/5 * * * * /usr/local/bin/backup.sh fast >> /var/log/cron.log 2>&1" > /etc/cron.d/gitbackup \
    && echo "0 */5 * * * /usr/local/bin/backup.sh force >> /var/log/cron.log 2>&1" >> /etc/cron.d/gitbackup \
    && chmod 0644 /etc/cron.d/gitbackup \
    && crontab /etc/cron.d/gitbackup

# Expose internal port
EXPOSE 25565

# Start cron in foreground and run server
CMD ["sh", "-c", "cron && /app/run.sh"]