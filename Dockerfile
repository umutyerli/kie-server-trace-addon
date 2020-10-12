FROM docker.artifactory.apps.ecicd.dso.ncps.us-cert.gov/openjdk/openjdk-8-rhel8:latest
EXPOSE 8090
ENV HOME /opt/app
ENV M2_HOME /home/jboss/.m2
ENV KJAR_VERSION 1.0.0-SNAPSHOT
ENV KJAR_ARTIFACT com.malware:AnalysisWorkflow:${KJAR_VERSION}
WORKDIR /opt/app

USER root

# Add kie server jar
COPY kie-server/target/*.jar /opt/app/target/app.jar

# Copy settings.xml into maven home
COPY kie-server/src/main/docker/settings.xml ${M2_HOME}/settings.xml

# Add kjar and pom.xml into maven local cache
RUN mkdir -p ${M2_HOME}/repository/com/malware/AnalysisWorkflow/${KJAR_VERSION}
COPY pam-orchestrator/target/AnalysisWorkflow-${KJAR_VERSION}.jar ${M2_HOME}/repository/com/malware/AnalysisWorkflow/${KJAR_VERSION}/AnalysisWorkflow-${KJAR_VERSION}.jar
COPY pam-orchestrator/pom.xml ${M2_HOME}/repository/com/malware/AnalysisWorkflow/${KJAR_VERSION}/AnalysisWorkflow-${KJAR_VERSION}.pom

# Add kie server state xml
COPY kie-server/AnalysisWorkflow-service.xml /opt/app/AnalysisWorkflow-service.xml

# Set correct file permissions on deployment and maven local cache
RUN chown -R jboss:jboss /opt/app
RUN chown -R jboss:jboss ${M2_HOME}

USER jboss

ENTRYPOINT java -jar -Dspring.profiles.active=openshift -Dkie.maven.settings.custom=/home/jboss/.m2/settings.xml -Dorg.guvnor.m2repo.dir=/home/jboss/.m2/repository /opt/app/target/app.jar