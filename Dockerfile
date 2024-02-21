FROM maven:3.6-jdk-8-alpine AS build

COPY tencent-settings.xml /usr/share/maven/conf/settings.xml

ADD . /tmp/

RUN cd /tmp \
    && mvn clean package -Dmaven.test.skip=true

RUN ls /tmp

FROM openjdk:8u342-jdk-buster

COPY apache-skywalking-java-agent-9.1.0.tgz /

RUN cd / && tar xf apache-skywalking-java-agent-9.1.0.tgz && rm -f apache-skywalking-java-agent-9.1.0.tgz

COPY --from=build /tmp/target/*.jar /spring-boot-demo.jar

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
