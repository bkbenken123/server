# Use OpenJDK 21 slim image
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /app

# Install necessary utilities
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Add Minecraft server jar from Mojang
ADD https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar /app/server.jar

# Copy server.properties and world folder if they exist
COPY server/server.properties /app/server.properties
COPY server/world /app/world

# Set JVM options (adjust RAM if needed)
ENV JVM_OPTS="-Xmx1024M -Xms512M"

# Optional: install ngrok if you want to expose your server publicly
# Uncomment the lines below if you have an NGROK_AUTHTOKEN build argument
ARG NGROK_AUTHTOKEN
RUN curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip -o ngrok.zip \
    && unzip ngrok.zip \
    && mv ngrok /usr/local/bin/ \
    && rm ngrok.zip \
    && ngrok config add-authtoken $NGROK_AUTHTOKEN

# Expose default Minecraft port
EXPOSE 25565

# Start Minecraft server
CMD ["sh", "-c", "java $JVM_OPTS -jar server.jar nogui"]
