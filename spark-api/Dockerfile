FROM jeffreymanning/spark-base

MAINTAINER Jeff Manning

#USER root

#install the basic packages - nss_wrapper requires epel
#RUN yum clean all
#RUN yum -y update && yum clean all

### change the ownership
# change ownership to the spark process (non-root)
#RUN useradd spark \
#    && echo "spark:spark" | chpasswd \
#	&& chown spark:spark /home/spark \
#    && usermod -aG wheel spark
# moved to centos-base
#RUN groupadd -r spark && useradd --no-log-init -r -g spark spark
#RUN usermod -aG wheel spark

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
WORKDIR /tmp

USER spark

# Start the main process
# looks for SPARK_MASTER_ADDRESS - $(SPARK_MASTER_ADDRESS)
# not meant to be run stand alone
#ENTRYPOINT ["/opt/spark/bin/spark-shell"]
#CMD ["--master $SPARK_MASTER_ADDRESS"]

