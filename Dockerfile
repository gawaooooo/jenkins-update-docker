FROM centos:centos7
ARG arg
ARG INITIAL_JENKINS_VERSION=2.204.2-1.1
ARG BACKUP_FILE=backup

ENV TZ='Asia/Tokyo'

RUN echo ${INITIAL_JENKINS_VERSION}; echo ${BACKUP_FILE}

RUN yum -y install java-1.8.0-openjdk && \
    curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo && \
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key && \
    curl -# -LO http://mirrors.jenkins-ci.org/redhat-stable/jenkins-${INITIAL_JENKINS_VERSION}.noarch.rpm && \
    rpm -ivh jenkins-${INITIAL_JENKINS_VERSION}.noarch.rpm && \
    yum -y install initscripts && \
    systemctl enable jenkins

# copy backup file
COPY ./backup/${BACKUP_FILE}.tar.gz /tmp
WORKDIR /tmp
RUN tar xzvf ${BACKUP_FILE}.tar.gz && \
    cp -R jenkins-backup/* /var/lib/jenkins  && \
    chown jenkins:jenkins -R /var/lib/jenkins
# copy jenkins update shell
COPY ./script/jenkins-update.sh /tmp

CMD ["/sbin/init"]
