FROM jeffreymanning/spark-base

MAINTAINER Jeff Manning

USER 185
#ENV USER_NAME=185
#USER spark
#ENV USER_NAME=spark
ENV NSS_WRAPPER_PASSWD=/tmp/passwd
ENV NSS_WRAPPER_GROUP=/etc/group
RUN touch ${NSS_WRAPPER_PASSWD}  && \
    chgrp 0 ${NSS_WRAPPER_PASSWD} && \
    chmod g+rw ${NSS_WRAPPER_PASSWD}

# Make the default PWD somewhere that the user can write. This is
# useful when connecting with 'oc run' and starting a 'spark-shell',
# which will likely try to create files and directories in PWD and
# error out if it cannot.
WORKDIR /tmp

# entrypoint actually adds user to NSS_WRAPPER_PASSWD (185 and group 185)
ENTRYPOINT ["/entrypoint"]

# Start the main process
CMD ["/opt/spark/bin/launch.sh"]
