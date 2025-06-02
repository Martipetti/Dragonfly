FROM ubuntu:latest
EXPOSE 8080

# Install Java, JavaFX, and javac to compile the project
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        openjdk-11-jdk \
        openjfx \
        wget \
        unzip \
    && apt-get clean \
    && rm -f /var/lib/apt/lists/*_dists_*

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Copy full source code
COPY . /app
WORKDIR /app/Drone-Route-Simulator

# Compile Java files (adjust src path and main class if needed)
RUN mkdir -p /app/out && \
    javac -d /app/out -cp /usr/share/openjfx/lib/* $(find ./src -name "*.java") && \
    cd /app/out && \
    jar cfe /app/Drone-Route-Simulator.jar MainClassName *

# Run the app (using JavaFX)
CMD java --module-path /usr/share/openjfx/lib \
         --add-modules javafx.controls,javafx.fxml \
         -jar Drone-Route-Simulator.jar
