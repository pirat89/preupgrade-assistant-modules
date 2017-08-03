#!/bin/bash

. /usr/share/preupgrade/common.sh

#END GENERATED SECTION

RESULT=$RESULT_INFORMATIONAL
rm -f solution.txt
if [[ -d /run ]]; then
  log_medium_risk "Conflict with the file structure: the /run directory already exists."
  echo \
"The actual data in the /run/ directory will not be accessible from the upgraded OS
because tmpfs will be mounted on this directory. Move the data.
" >> solution.txt
  RESULT=$RESULT_FAIL
elif [[ -e /run ]];then
  # improbably situation
  log_medium_risk "Conflict with the file structure: the /run file already exists."
  echo \
"The /run file cannot be used as a mountpoint and it will be removed during the in-place
upgrade. The /run/ directory will be created instead.
" >> solution.txt
  RESULT=$RESULT_FAIL
fi

echo \
"In Red Hat Enterprise Linux 7 the /run/ directory is the place where tmpfs is mounted for runtime data.
The original /var/run/ directory is a symbolic link to /run/ and likewise /var/lock/ points
to /run/lock/ now. The /run/ directory is emptied on reboot, so all runtime
files must be created on boot again. See Red Hat Enterprise Linux 7 Migration Planning Guide." \
  >> solution.txt

exit $RESULT
