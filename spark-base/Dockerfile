FROM jeffreymanning/centos7-base

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
      io.openshift.expose-services="" \
      io.openshift.tags="centos7,spark,java,maven"

USER root

#install the basic packages - nss_wrapper requires epel
RUN yum clean all
RUN yum install -y epel-release && yum -y update && yum clean all -y && rm -rf /var/cache/yum

# spark pre-reqs...  if no hadoop, need log4j to install
# none yet

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

# not meant to be dxirectly run..; spark node is meant to be run
#USER spark
#WORKDIR ${SPARK_HOME}
#
#### NSS_WRAPPER for user name recognition at runtime w/ an arbitrary uid - for OpenShift deployments
#ENTRYPOINT [ "/entrypoint" ]
#
### Start the main process (app-root from base)
#CMD run

CMD ${SPARK_HOME}/bin2/run
