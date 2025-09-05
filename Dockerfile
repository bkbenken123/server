# Use OpenJDK 21 slim image
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /app

# Download your chosen Minecraft server JAR
ADD https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar /app/server.jar

# Accept Mojang's EULA
RUN echo "eula=true" > eula.txt

# Expose Minecraft default port
EXPOSE 25565

# JVM options (adjust memory if needed)
ENV JVM_OPTS="-Xmx2G -Xms1G"

# Start the server
CMD ["sh", "-c", "java $JVM_OPTS -jar server.jar nogui"]
