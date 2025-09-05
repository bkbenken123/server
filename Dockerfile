# Use OpenJDK 21 (Minecraft 1.21+ requires Java 21)
FROM openjdk:21-jdk-slim

# Set working directory
WORKDIR /app

# Download Minecraft server jar
ADD https://piston-data.mojang.com/v1/objects/df37f51ac3aaee47cebb6a42199d9db6466bcb2e/server.jar /app/server.jar

# Accept EULA
RUN echo "eula=true" > eula.txt

# Expose Minecraft port (Koyeb maps this automatically)
EXPOSE 25565

# Default memory allocation (adjust if needed)
ENV JVM_OPTS="-Xmx2G -Xms2G"

# Run the server
CMD ["sh", "-c", "java $JVM_OPTS -jar server.jar nogui"]
