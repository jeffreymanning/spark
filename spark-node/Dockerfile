FROM jeffreymanning/spark-base

MAINTAINER Jeff Manning
LABEL name="spark-node" \
      summary="MITRE's spark node image (worker or master only)" \
      description="Centos7, spark 2.1.1 base image for master worker nodes" \
### Required labels above - recommended below
      io.k8s.description="Centos, Spark 2.1.1 master and worker nodes with arbitrary UID support" \
      io.k8s.display-name="Centos, Spark 2.1.1 master and worker nodes" \
      io.openshift.expose-services="spark"

USER root

# see https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-nsswrapper/Dockerfile.centos7
# using nss_wrapper to support arbitrary UID assignment (openshift security)
RUN INSTALL_PKGS="nss_wrapper gettext" && \
    yum -y install --setopt=tsflags=nodocs ${INSTALL_PKGS} && \
    yum clean all -y

# spark user setup
# see https://docs.openshift.org/latest/creating_images/guidelines.html
# By default, OpenShift Origin runs containers using an arbitrarily assigned user ID. This provides additional
# security against processes escaping the container due to a container engine vulnerability and thereby achieving
# escalated permissions on the host node.

# For an image to support running as an arbitrary user, directories and files that may be written to by
# processes in the image should be owned by the root group and be read/writable by that group.
# Files to be executed should also have group execute permissions.

### Setup user for build execution and application runtime
# see https://github.com/RHsyseng/container-rhel-examples/blob/master/starter-epel/Dockerfile
#RUN mkdir -p ${SPARK_HOME}/bin2
COPY bin/entrypoint ${SPARK_HOME}/bin2/
#ENV PATH=$PATH:${SPARK_HOME}/bin2
RUN chmod -R ug+x ${SPARK_HOME}/bin2/entrypoint && sync

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
#RUN groupadd -r spark && useradd -r -s /bin/false -d ${SPARK_HOME} -u 185 -g spark spark && \
#    usermod -aG wheel spark && \
#    usermod -aG 0 spark && \
#    chown -R -L spark:0 ${SPARK_HOME} && \
#    chmod -R g=u ${SPARK_HOME}

# RUN chown -R -L spark:spark ${SPARK_HOME}
ENV USER_NAME=spark \
    USER_ID=1002 \
    NSS_WRAPPER_PASSWD=/tmp/passwd \
    NSS_WRAPPER_GROUP=/tmp/group

# see https://github.com/atbentley/docker-nss-wrapper
#ENV NSS_WRAPPER_PASSWD=/tmp/passwd NSS_WRAPPER_GROUP=/tmp/group
RUN touch ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} && \
    chgrp 0 ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP} && \
    chmod g+rw ${NSS_WRAPPER_PASSWD} ${NSS_WRAPPER_GROUP}

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
WORKDIR ${SPARK_HOME}
USER spark

# entrypoint actually adds user to NSS_WRAPPER_PASSWD
ENTRYPOINT ["bin2/entrypoint"]

# Start the main process
CMD ${SPARK_HOME}/bin/launch.sh
