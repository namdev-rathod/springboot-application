# Use a base image with OpenJDK 17
FROM openjdk:17-jdk-slim

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean;

# Set the working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Build the project
RUN mvn clean package

# Expose port 8080
EXPOSE 8080

# Command to run the JAR file
ENTRYPOINT ["java", "-jar", "target/springboot-0.0.1-SNAPSHOT.jar"]
