FROM maven:3.6-jdk-8-alpine AS build

# 设置腾讯云镜像源
RUN mkdir -p /usr/share/maven/conf && \
    echo "<settings>\n\
            <mirrors>\n\
                <mirror>\n\
                    <id>mirrorId</id>\n\
                    <mirrorOf>central</mirrorOf>\n\
                    <name>Tencent Cloud Maven Mirror</name>\n\
                    <url>https://mirrors.cloud.tencent.com/nexus/repository/maven-public/</url>\n\
                    <layout>default</layout>\n\
                    <mirrorOfLayouts>default</mirrorOfLayouts>\n\
                    <blocked>false</blocked>\n\
                    <releases><enabled>true</enabled></releases>\n\
                    <snapshots><enabled>true</enabled></snapshots>\n\
                </mirror>\n\
            </mirrors>\n\
        </settings>" \
    > /usr/share/maven/conf/settings.xml
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
