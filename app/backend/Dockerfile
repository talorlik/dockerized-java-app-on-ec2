###############################################################################
# Multi-stage Dockerfile for Java 21 Spring Boot backend.
#
# Stage 1: Maven build (with build cache layer).
# Stage 2: Eclipse Temurin 21 JRE Alpine, non-root user.
###############################################################################

# ----- builder -----
FROM maven:3.9-eclipse-temurin-21 AS builder
WORKDIR /build

# Cache dependencies first
COPY pom.xml ./
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q -DskipTests package

# ----- runtime -----
FROM eclipse-temurin:21-jre-alpine AS runtime

# Non-root
RUN addgroup -S app && adduser -S -G app app

# curl for healthchecks
RUN apk add --no-cache curl

WORKDIR /app
COPY --from=builder /build/target/app.jar /app/app.jar

USER app
EXPOSE 8080

# Sane JVM defaults for containers (sized via cgroup, exit on OOM, UTF-8).
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -Dfile.encoding=UTF-8 -Duser.timezone=UTC"

HEALTHCHECK --interval=15s --timeout=3s --start-period=30s --retries=10 \
  CMD curl -fsS http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
