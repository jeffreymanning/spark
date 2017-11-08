#!/bin/bash

# mounting volumes (gluster) and running into permission issues.
# Specifically within spark environment:
#   spark nodes run as spark with within various groups (root, 185, wheel)
#   API nodes (rstudio, zeppelin) run as normal users (rstudio and zeppelin) but are added to spark groups (root(0), 185)
#
# while accessing volume from different users (zeppelin) asks spark (in another container) to write out parquet file
# groups are not give write permission (w) by default.
# groups will require write permission
umask 0002

exec "$@"
