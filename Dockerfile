# Use OpenJDK 21 slim as base
FROM openjdk:21-jdk-slim



# Set working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download Minecraft server
ADD https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar /app/server.jar

# Copy server configuration and world
COPY server/server.properties /app/server.properties
COPY server/world /app/world

# Optional: ngrok auth token
ARG NGROK_AUTHTOKEN

# Install ngrok
RUN curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip -o ngrok.zip \
    && unzip ngrok.zip \
    && mv ngrok /usr/local/bin/ \
    && rm ngrok.zip \
    && if [ -n "$NGROK_AUTHTOKEN" ]; then ngrok config add-authtoken $NGROK_AUTHTOKEN; fi



# Set Java options (optional)
ENV JVM_OPTS="-Xmx480M -Xms128M"

# Expose default Minecraft port
EXPOSE 25565

echo "eula=true" > eula.txt

# Start server
CMD ["sh", "-c", "java $JVM_OPTS -jar server.jar nogui"]
