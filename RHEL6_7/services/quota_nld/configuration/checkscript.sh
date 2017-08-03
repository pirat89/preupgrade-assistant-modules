#!/bin/bash
. /usr/share/preupgrade/common.sh
#END GENERATED SECTION

function solution() {
    printf '%s\n\n' "$@" | fold -s >> "$SOLUTION_FILE" || exit_error
}

# Return true if first argument is a configuration changed since system
# installation.
function config_file_changed() {
    grep -q -P "\\s\\Q${1}\\E\\z" "$VALUE_CONFIGCHANGED"
}

CONF_FILE='/etc/sysconfig/quota_nld'

solution 'The quota_nld service configuration is fully compatible.'

if [ ! -e "$CONF_FILE" ]; then
    solution 'The service configuration is missing on the old system.'
    solution 'The default configuration will be used on the new system.'
    exit_pass
fi

# backup_config_file() does not save into cleanconf
if config_file_changed  "${CONF_FILE}"; then
    solution 'The service configuration has been modified since the installation.'

    mkdir -p "${VALUE_TMP_PREUPGRADE}/cleanconf/$(dirname ${CONF_FILE})" || \
        exit_error
    cp -p "$CONF_FILE" "${VALUE_TMP_PREUPGRADE}/cleanconf" || exit_error

    solution "The configuration file \"${CONF_FILE}\" has been backed up.
It can be used on the new system safely."
    exit_fixed
fi

solution 'The service is in factory settings.'
solution 'The default configuration will be used on the new system.'
exit_pass

