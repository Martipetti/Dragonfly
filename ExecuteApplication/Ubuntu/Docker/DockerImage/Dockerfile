FROM openjdk:8-jdk

WORKDIR /app

COPY . /app

RUN mkdir -p out && \
    javac -d out $(find src -name "*.java")

RUN jar cfe app.jar controller.MainController -C out .

CMD ["java", "-jar", "app.jar"]
