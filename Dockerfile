# Debian base so apt-get works
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git cron bash \
 && rm -rf /var/lib/apt/lists/*

# Install JDK 24 from tar.gz
# Set JDK_URL to the correct architecture:
# - ARM64: https://download.java.net/java/GA/jdk24/latest/binaries/jdk-24_linux-aarch64_bin.tar.gz
# - x86_64: https://download.java.net/java/GA/jdk24/latest/binaries/jdk-24_linux-x64_bin.tar.gz
ENV JAVA_HOME=/opt/jdk
ENV PATH="$JAVA_HOME/bin:${PATH}"
ARG JDK_URL="https://download.java.net/java/GA/jdk24/latest/binaries/jdk-24_linux-aarch64_bin.tar.gz"
RUN set -eux; \
    mkdir -p /opt/jdk; \
    curl -fsSL "$JDK_URL" -o /tmp/jdk.tgz; \
    tar -xzf /tmp/jdk.tgz -C /opt/jdk --strip-components=1; \
    rm -f /tmp/jdk.tgz; \
    java -version

# Set working directory
WORKDIR /app

# Copy server folder into container
COPY server/ /app

# Make run.sh executable
RUN chmod +x /app/run.sh

# Copy backup script
COPY backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Setup cron jobs for auto-backup
RUN echo "*/5 * * * * /usr/local/bin/backup.sh fast >> /var/log/cron.log 2>&1" > /etc/cron.d/gitbackup \
    && echo "0 */5 * * * /usr/local/bin/backup.sh force >> /var/log/cron.log 2>&1" >> /etc/cron.d/gitbackup \
    && chmod 0644 /etc/cron.d/gitbackup \
    && crontab /etc/cron.d/gitbackup

# Expose internal port 25565
EXPOSE 25565

# Start cron and run server
CMD service cron start && /app/run.sh