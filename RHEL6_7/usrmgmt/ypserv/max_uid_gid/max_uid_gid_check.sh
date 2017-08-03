#!/bin/bash
#
# Author: Honza Horak <hhorak@redhat.com>
#
# Description:
# This script checks that there are some users with UID between 500 and 1000,
# which can make problems after upgrading to RHEL 7, because MINUID was changed
# to 1000 in RHEL 7. Users with UID between 500 and 1000 can be excluded from
# lookup results, which is wrong.
# It uses current domainname set and tries to open passwd.byuid map in
# the current domain.

. /usr/share/preupgrade/common.sh

#END GENERATED SECTION

check_root

. ../common.sh

ypserv_configured || exit $RESULT_NOT_APPLICABLE

get_domainname

 ./dangerous_uid.py "$DOMAINNAME"

UID_RESULT=$?

if [ $UID_RESULT -eq 2 ] ; then
    exit $RESULT_NOT_APPLICABLE
fi

read -r -d '' SOLUTION <<'EOF'
There are some UIDs between 500 and 1000 in passwd.byuid NIS map.
This might cause troubles after the upgrade, because MINUID/MINGID
is 1000 by default in Red Hat Enterprise Linux 7. Checking for the proper MINUID/MINGID
settings or changing UID/GID for such users is advised.

Check UIDs/GIDs in the source file for passwd.byuid NIS map to correspond
with /etc/login.defs after the upgrade.
EOF

if [ $UID_RESULT -eq 0 ] ; then
    log_high_risk "There are some UIDs between 500 and 1000 in passwd.byuid NIS map."
    solution_file "$SOLUTION"
    exit_fail
fi

exit $RESULT_PASS

