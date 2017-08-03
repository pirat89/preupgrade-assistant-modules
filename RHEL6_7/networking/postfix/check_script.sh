#!/bin/bash

. /usr/share/preupgrade/common.sh
check_applies_to "postfix"
check_rpm_to "" ""
COMPONENT="postfix"
#END GENERATED SECTION

function solution()
{
  printf '%s\n\n' "$@" | fold -s | sed 's/ \+$//' >> "$SOLUTION_FILE" || exit_error
}

# Copy your config file from RHEL6 (in case of scenario RHEL6_7) 
# to Temporary Directory
CONFIG_FILE="/etc/postfix/main.cf"

[ -f "$CONFIG_FILE" ] ||
  exit_not_applicable

# This check can be used if you need root privilegues
check_root


mkdir -p $VALUE_TMP_PREUPGRADE/cleanconf/$(dirname $CONFIG_FILE)
cp $CONFIG_FILE $VALUE_TMP_PREUPGRADE/cleanconf/$CONFIG_FILE


# Now check your configuration file for options
# and for other stuff related with configuration

# If configuration can be used on target system (like RHEL7 in case of RHEL6_7)
# the exit should be RESULT_PASS

# If configuration can not be used on target system (like RHEL 7 in case of RHEL6_7)
# scenario then result should be RESULT_FAILED. Correction of 
# configuration file is provided either by solution script
# or by postupgrade script located in $VALUE_TMP_PREUPGRADE/postupgrade.d/

# if configuration file can be fixed then fix them in temporary directory
# $VALUE_TMP_PREUPGRADE/$CONFIG_FILE and result should be RESULT_FIXED
# More information about this issues should be described in solution.txt file
# as reference to KnowledgeBase article.

# postupgrade.d directory from your content is automatically copied by
# preupgrade assistant into $VALUE_TMP_PREUPGRADE/postupgrade.d/ directory

#workaround to openscap buggy missing PATH
export PATH=$PATH:/usr/bin

solution "Upgrade your configuration by:\
  postfix upgrade-configuration"

solution "If you plan to use a postscreen daemon, restart the postfix service \
by:
  systemctl restart postfix"

solution "There is a new smtpd_relay_restrictions parameter with the built-in
default settings:

    smtpd_relay_restrictions =
    permit_mynetworks
    permit_sasl_authenticated
    defer_unauth_destination

This safety net prevents open relay problems due to mistakes
with spam filter rules in smtpd_recipient_restrictions.

If your site has a complex mail relay policy configured under
smtpd_recipient_restrictions, this safety net may defer mail that
Postfix should accept.

To fix this safety net, take one of the following actions:

- Set smtpd_relay_restrictions empty, and keep using the existing
  mail relay authorization policy in smtpd_recipient_restrictions.

- Copy the existing mail relay authorization policy from
  smtpd_recipient_restrictions to smtpd_relay_restrictions.

There is no need to change the value of smtpd_recipient_restrictions."

exit_informational
