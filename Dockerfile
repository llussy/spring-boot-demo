FROM maven:3.6-jdk-8-alpine AS build

ADD . /tmp/

RUN cd /tmp \
    && mvn clean package -Dmaven.test.skip=true

FROM openjdk:8u342-jdk-buster
ADD https://archive.apache.org/dist/skywalking/9.2.0/apache-skywalking-apm-9.2.0.tar.gz /

RUN cd / && tar xf apache-skywalking-apm-9.2.0.tar.gz && rm -f apache-skywalking-apm-9.2.0.tar.gz

COPY --from=build /tmp/spring-boot-demo/target/*.jar /spring-boot-demo.jar

CMD ["java", \
    "-XX:MinRAMPercentage=75.0", \
    "-XX:MaxRAMPercentage=75.0", \
    "-XX:InitialRAMPercentage=75.0", \
    "-XX:+HeapDumpAfterFullGC", \
    "-XX:HeapDumpPath=/dump", \
    "-XX:ErrorFile=/dump/hs_err_pid_%p.log", \
    "-XX:-UseAdaptiveSizePolicy", \
    "-javaagent:/skywalking-agent/skywalking-agent.jar", \
    "-Dskywalking.agent.service_name=spring-boot-demo", \
    "-Dskywalking.collector.backend_service=skywalking-skywalking-helm-oap.monitoring.svc.cluster.local:11800", \
    "-XX:+UseG1GC", \
    "-Duser.timezone=Asia/Shanghai", \
    "-jar", \
    "/spring-boot-demo.jar"]
