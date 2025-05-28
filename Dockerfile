# Use an official Java runtime as a parent image
FROM openjdk:8-jdk-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the entire project into the container
COPY . .

# Compile the Java files (if necessary)
RUN javac -d src/main/classes src/util/*.java

# If there are additional dependencies, you may need to include them
# For example, if you have external libraries, copy them to a lib directory
# COPY lib/* /app/lib/

# Command to run the application
CMD ["java", "-cp", "src/main/classes:src/lib/*", "util.DroneAnalyzerLog"]