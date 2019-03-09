FROM registry.fedoraproject.org/fedora:29

ARG MAVEN_VERSION=3.6.0
ARG GRAAL_VM_VERSION=1.0.0-rc12
ARG USER_HOME_DIR="/root"
ARG SHA=fae9c12b570c3ba18116a4e26ea524b29f7279c17cbaadc3326ca72927368924d9131d11b9e851b8dc9162228b6fdea955446be41207a5cfc61283dd8a561d2f
ARG MAVEN_BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries
ARG GRAAL_VM_BASE_URL=https://github.com/oracle/graal/releases/download/vm-${GRAAL_VM_VERSION}
ARG INSTALL_PKGS="buildah findutils podman bzip2-devel gcc-c++ libcurl-devel openssl-devel tar unzip bc which lsof gzip"

USER root

RUN dnf -y update \
    && dnf install -y $INSTALL_PKGS \
    && mkdir -p /usr/share/maven /usr/share/maven/ref \
    && curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
    && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
    && mkdir -p /opt/graalvm  \
    && curl -fsSL -o /tmp/graalvm-ce-amd64.tar.gz ${GRAAL_VM_BASE_URL}/graalvm-ce-${GRAAL_VM_VERSION}-linux-amd64.tar.gz \
    && tar -xzf /tmp/graalvm-ce-amd64.tar.gz -C /opt/graalvm --strip-components=1  \
    && yum clean all \
    && rm -f /tmp/apache-maven.tar.gz  /tmp/graalvm-ce-amd64.tar.gz \
    && rm -rf /var/cache/yum \
    && mkdir -p /project


ENV MAVEN_HOME /opt/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV GRAALVM_HOME /opt/graalvm
ENV JAVA_HOME /opt/graalvm
ENV BUILDAH_SCRIPT /usr/local/bin/buildah.sh

COPY entrypoint-run.sh /usr/local/bin/entrypoint-run.sh
COPY settings.xml /usr/share/maven/ref
COPY buildah.sh /usr/local/bin/buildah.sh

WORKDIR /project

ENTRYPOINT [ "/usr/local/bin/entrypoint-run.sh" ]
CMD [ "mvn","-v" ]