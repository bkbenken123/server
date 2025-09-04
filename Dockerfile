# Use a minimal Linux base image
FROM ubuntu:22.04

# Install required packages and clean up
RUN apt-get update && \
    apt-get install -y tar cron wget sha256sum && \
    rm -rf /var/lib/apt/lists/*

# Set working directory for JDK
WORKDIR /opt/jdk

# Copy your local JDK tar.gz into the image
COPY jdk-24_linux-aarch64_bin.tar.gz /tmp/jdk.tar.gz

# Verify SHA256 checksum
RUN echo "b4e4273c290c7cecdab499fb0729ce9e4bf92de54e109c4f5a942a30e63d0311  /tmp/jdk.tar.gz" | sha256sum -c -

# Extract JDK
RUN tar -xzf /tmp/jdk.tar.gz --strip-components=1 -C /opt/jdk && \
    rm -f /tmp/jdk.tar.gz

# Set JAVA_HOME and PATH
ENV JAVA_HOME=/opt/jdk
ENV PATH="$JAVA_HOME/bin:$PATH"

# Verify Java installation
RUN java -version

# Set working directory for server
WORKDIR /app

# Copy server folder and make run.sh executable
COPY server/ /app
RUN chmod +x /app/run.sh

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