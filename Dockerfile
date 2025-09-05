# Use a minimal Linux base image
FROM ubuntu:22.04

# Install OpenJDK 21 and curl
RUN apt-get update && \
    apt-get install -y openjdk-21-jdk curl && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME and PATH
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Create working directory
WORKDIR /app

# Download Minecraft 1.21.8 server JAR from Mojang
RUN curl -L -o server.jar https://piston-data.mojang.com/v1/objects/6bce4ef400e4efaa63a13d5e6f6b500be969ef81/server.jar

# Accept EULA automatically
RUN echo "eula=true" > eula.txt

# Expose Minecraft default port
EXPOSE 25565

# Run the Minecraft server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]
