FROM fabric8/java-jboss-openjdk8-jdk:1.5.2

ARG MAVEN_VERSION=3.5.0
ARG GRAAL_VM_VERSION=1.0.0-rc10
ARG MAVEN_BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries
ARG GRAAL_VM_BASE_URL=https://github.com/oracle/graal/releases/download/vm-${GRAAL_VM_VERSION}

USER root

RUN yum -y update \
    && mkdir -p /opt/maven \
    && curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    && tar -xzf /tmp/apache-maven.tar.gz -C /opt/maven --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz \
    && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
    && mkdir -p /opt/graalvm  \
    && curl -fsSL -o /tmp/graalvm-ce-amd64.tar.gz ${GRAAL_VM_BASE_URL}/graalvm-ce-${GRAAL_VM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/graalvm-ce-amd64.tar.gz -C /opt/graalvm --strip-components=1  \
    && yum clean all

USER jboss

ENV M2_HOME /opt/maven
ENV GRAALVM_HOME /opt/graalvm

VOLUME ["/home/jboss/.m2"]

ENTRYPOINT [ "mvn" ]