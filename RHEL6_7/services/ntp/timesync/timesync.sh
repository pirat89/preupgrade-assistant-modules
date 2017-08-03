#!/bin/bash
. /usr/share/preupgrade/common.sh
#END GENERATED SECTION

# Check if the ntpdate service is enabled
/sbin/chkconfig ntpdate || exit_pass

cat > $SOLUTION_FILE <<-EOF

The ntpdate service is enabled on this system. In Red Hat Enterprise Linux 7 the system services are
managed by systemd, which starts services in parallel unless an ordering
dependency is specified. If you have a service that needs to be started after
the system clock was set by ntpdate, in Red Hat Enterprise Linux 7 you will need to add
"After=time-sync.target" to the systemd unit file of the service.

The time-sync target is provided also by other services available in Red Hat Enterprise Linux 7.
They can be used as a replacement of the ntpdate service. The services are
ntp-wait from the ntp-perl package (which waits until the ntpd service has
synchronized the clock), sntp service from the sntp package, and chrony-wait
service from the chrony package(which waits until the chronyd service has
synchronized the clock).

See the Red Hat Enterprise Linux 7 System Administrator's Guide for more information.
EOF

exit_informational
