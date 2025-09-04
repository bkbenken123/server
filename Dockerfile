# Set working directory for JDK
WORKDIR /opt/jdk

# Copy JDK tar.gz from the repo into the image
COPY jdk-24_linux-aarch64_bin.tar.gz /tmp/jdk.tgz

# Extract JDK
RUN mkdir -p /opt/jdk && \
    tar -xzf /tmp/jdk.tgz -C /opt/jdk --strip-components=1 && \
    rm -f /tmp/jdk.tgz

# Verify Java installation
RUN java -version

# Set working directory for server
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