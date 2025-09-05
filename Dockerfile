ROM openjdk:21-jdk-slim

WORKDIR /app

# Install curl and unzip for ngrok
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download Minecraft server JAR
ADD https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar /app/server.jar

# Copy your config + world files from repo into container
COPY server.properties /app/server.properties
COPY world /app/world

# Download ngrok
RUN curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip -o ngrok.zip \
    && unzip ngrok.zip -d /usr/local/bin \
    && rm ngrok.zip

# Accept EULA
RUN echo "eula=true" > eula.txt

EXPOSE 25565

# JVM options for Koyeb free plan
ENV JVM_OPTS="-Xmx480M -Xms128M"

# Pass ngrok auth token at runtime via ENV
ENV NGROK_AUTHTOKEN=""

# Start both ngrok and Minecraft
CMD ngrok config add-authtoken $NGROK_AUTHTOKEN && \
    ngrok tcp 25565 --log stdout & \
    java $JVM_OPTS -jar server.jar nogui
