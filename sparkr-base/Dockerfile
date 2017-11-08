FROM jeffreymanning/r-base-pkgs

MAINTAINER Jeff Manning
LABEL name="spark-base" \
      vendor="MITRE Corp" \
      version="2.1" \
      release="1" \
      summary="MITRE's base spark image - ${version}.${release}" \
      description="Centos7, spark ${version}.${release} base image for master worker api nodes" \
### Required labels above - recommended below
      io.k8s.description="Centos, Spark 2.1.1 base image, non-executable" \
      io.k8s.display-name="centos, spark ${version}.${release}" \
      io.openshift.expose-services="spark" \
      io.openshift.tags="centos7,spark,java,maven"

USER root

# see r-base
##install the basic packages - nss_wrapper requires epel
#RUN yum clean all -y && \
## spark pre-reqs...  if no hadoop, need log4j to install
## only java is real requirement...  but ssl and curl are used from this point forward in docker layers
#    INSTALL_PKGS="epel-release libcurl libcurl-devel openssl openssl-devel" && \
#    yum install -y --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
#    yum -y update && \
#    yum clean all -y && \
#    rm -rf /var/cache/yum

## Install Spark
ARG SPARK_MAJOR_VERSION=2
ARG SPARK_UPDATE_VERSION=1
ARG SPARK_MINOR_VERSION=1
ARG SPARK_VERSION=spark-${SPARK_MAJOR_VERSION}.${SPARK_UPDATE_VERSION}.${SPARK_MINOR_VERSION}
ARG SPARK_HREF_ROOT="https://archive.apache.org/dist/spark"

# currently not using hadoop - deploy standalone
ARG DISTRO_NAME_HADOOP=${SPARK_VERSION}-bin-hadoop2.7

## caution with no hadoop...  the slfj...  jars are not included with the binary distribution
ARG DISTRO_NAME_NO_HADOOP=${SPARK_VERSION}-bin-without-hadoop
ARG DISTRO_NAME=${DISTRO_NAME_HADOOP}
ARG DISTRO_LOC=${SPARK_HREF_ROOT}/${SPARK_VERSION}/${DISTRO_NAME}.tgz

RUN cd /opt && \
    curl $DISTRO_LOC \
    | gunzip \
    | tar -x && \
    ln -s $DISTRO_NAME spark

# setup the environment variables for Spark
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:${SPARK_HOME}/bin

# Adding jmx by default
COPY metrics /opt/spark

# Configure spark (conf dir files)
COPY scripts /tmp/scripts
RUN [ "bash", "-x", "/tmp/scripts/spark/install" ]

#cleanp scripts
RUN rm -rf /tmp/scripts

### Setup user for build execution and application runtime
# see https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-epel/Dockerfile
RUN mkdir -p ${SPARK_HOME}/bin2
COPY bin/run ${SPARK_HOME}/bin2/
RUN chmod -R ug+x ${SPARK_HOME}/bin2 && sync

COPY entrypoint.sh /
RUN chmod -R ug+x /entrypoint.sh && sync

####  NSS Wrapper setup (moved to spark-node)
# NSS Wrapper to modify /etc/passwd so arbitrary UIDs (185 above) can run and still have a username.
# Useful in environments such as Openshift which randomise the UID for each container
# Use the $USER_NAME environment variable to configure the name for the user.
#
# problem manifests itself in a login failure:
#       Exception in thread "main" java.io.IOException: failure to login
#           at org.apache.hadoop.security.UserGroupInformation.loginUserFromSubject(UserGroupInformation.java:824)
#           ... or equivalent
# looks to be an issue with OS login of users..
# see  https://stackoverflow.com/questions/41864985/hadoop-ioexception-failure-to-login
#
# see https://docs.openshift.org/latest/creating_images/guidelines.html
# By default, OpenShift Origin runs containers using an arbitrarily assigned user ID. This provides additional
# security against processes escaping the container due to a container engine vulnerability and thereby achieving
# escalated permissions on the host node.

# For an image to support running as an arbitrary user, directories and files that may be written to by
# processes in the image should be owned by the root group and be read/writable by that group.
# Files to be executed should also have group execute permissions.

# group 0 is the root group..  this is not root privs
# works
# later down docker layer chain with mounted volumes
# primary group must be rook
#
# need to get umask set to 002; therefore id -un must equal id -gn (/etc/profile) and
# must also be in group root
ENV USER_NAME=spark
ENV USER_UID=1002
RUN groupadd -g ${USER_UID} ${USER_NAME} && \
#    useradd -r -s /bin/false -d ${SPARK_HOME} -u 185 -g 0 spark && \
#    useradd -s /bin/false -d ${SPARK_HOME} -u 1000 -g spark spark && \
#    useradd -d ${SPARK_HOME} -u 1000 -g spark spark && \
    useradd -u ${USER_UID}  -g ${USER_NAME} ${USER_NAME} && \
    usermod -aG wheel ${USER_NAME} && \
#    usermod -aG spark spark && \
    usermod -aG root ${USER_NAME} && \
#    usermod -aG staff ${USER_NAME} && \
    usermod -aG default ${USER_NAME} && \
    chown -R -L ${USER_NAME}:root ${SPARK_HOME} && \
    chmod -R g=u ${SPARK_HOME}
#    echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER_NAME} && \
#    chmod 0440 /etc/sudoers.d/${USER_NAME}

#RUN cp /etc/profile /etc/profile.d/spark.sh
# SELinux
#
# By default, SELinux does not allow writing from a pod to a remote Gluster (NFS, ...) server.
# Note, deceptively, the NFS volume mounts correctly, but is read-only.
#
# To enable writing in SELinux on each node:
# -P makes the bool persistent between reboots.
# RUN  setsebool -P virt_use_nfs 1

# not meant to be directly run..; spark node is meant to be run
#USER spark

#WORKDIR ${SPARK_HOME}

#### umask to allow group writes; umask only works if it is run by a builtin command.
# Do not call the script by name but rather call . script to let it be executed by the current shell process.
#ENTRYPOINT [ ". /entrypoint.sh" ]
#RUN umask 002

### Start the main process (app-root from base)
#CMD run
# not meant to be dxirectly run..; spark node is meant to be run
WORKDIR ${SPARK_HOME}
USER spark
CMD ${SPARK_HOME}/bin2/run
