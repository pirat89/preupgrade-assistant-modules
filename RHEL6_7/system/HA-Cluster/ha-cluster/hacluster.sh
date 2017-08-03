#!/bin/bash

. /usr/share/preupgrade/common.sh

#END GENERATED SECTION

if [ ! -f "$VALUE_RPM_RHSIGNED" ]; then
    log_error "The $VALUE_RPM_RHSIGNED file is required."
    exit_error
fi

PACKAGE_LIST="modcluster cluster clustermon corosync luci pacemaker pcs rgmanager ricci openais foghorn ccs cluster-glue"

CLUSTER_CONFIG="/etc/cluster/cluster.conf"
COROSYNC_CONFIG="/etc/corosync/corosync.conf"

found=0
packages=""
for pkg in $PACKAGE_LIST;
do
    grep -q "^$pkg[[:space:]]" $VALUE_RPM_QA && is_dist_native $pkg
    if [ $? -eq 0 ]; then
        log_info "The $pkg package is installed."
        packages="$packages $pkg"
        found=1
    fi
done
if [ $found -eq 1 ]; then
    log_extreme_risk "High Availability Add-On packages are installed. The upgrade is not possible."
    echo "If you do not use the following cluster&HA related packages:$packages , uninstall them and run the Preupgrade Assistant again." >>hacluster.txt
    exit_fail
fi

if [ -f "$CLUSTER_CONFIG" ] || [ -f "$COROSYNC_CONFIG" ]; then
    log_extreme_risk "High Availability Add-On config files $CLUSTER_CONFIG or $COROSYNC_CONFIG exist. The upgrade is not possible."
    exit_fail
fi

exit_pass

