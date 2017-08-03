#!/bin/bash

. /usr/share/preupgrade/common.sh
#END GENERATED SECTION

FSTAB="/etc/fstab"

log_debug "The script checks if the /usr/ directory is on a separate partition."
log_debug "Checking the $FSTAB file"
grep [[:space:]]/usr[[:space:]] $FSTAB > /dev/null
if [ $? -eq 0 ]; then
    log_extreme_risk "The /usr/ directory is on a separate partition. The in-place Upgrade is not possible."
    exit $RESULT_FAIL
fi
log_debug "Checking $FSTAB file done"
log_debug "The /usr/ directory is not on a separate partition. The in-place upgrade is possible"
exit $RESULT_PASS
