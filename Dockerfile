# Use OpenJDK 21 slim image
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /app

# Install necessary tools
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Set JVM memory options (adjust as needed)
ENV JVM_OPTS="-Xmx1024M -Xms512M"

# Download Minecraft server jar
ADD https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar /app/server.jar

# Copy server properties if exists
# Optional: will ignore if file not present
COPY server.properties /app/server.properties
# Copy world folder if exists
COPY world /app/world

# Download ngrok if you want to expose your server publicly
# Optional: Comment out if not needed
RUN curl -s https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -o ngrok.zip \
    && unzip ngrok.zip \
    && rm ngrok.zip

# Add ngrok authtoken via build argument
ARG NGROK_AUTHTOKEN
RUN if [ ! -z "$NGROK_AUTHTOKEN" ]; then ./ngrok config add-authtoken $NGROK_AUTHTOKEN; fi

# Expose Minecraft default port
EXPOSE 25565

# Start script
CMD bash -c "\
    echo 'eula=true' > eula.txt; \
    if [ -f /app/server.properties ]; then echo 'Using provided server.properties'; fi; \
    java $JVM_OPTS -jar server.jar nogui & \
    if [ -f ./ngrok ]; then ./ngrok tcp 25565; else wait; fi"
