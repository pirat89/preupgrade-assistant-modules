#!/bin/bash

. /usr/share/preupgrade/common.sh

#END GENERATED SECTION

BACULA_ETC=/etc/bacula
BACULA_CONF=/etc/bacula/bacula-dir.conf
BACULA_SQL=/etc/bacula/query.sql

COMPONENT=bacula
log_info "Check whether $BACULA_ETC has correct user and group IDs."

exit_code=0
if [ -d "$BACULA_ETC" ]; then
    USER=`stat --format="%u" $BACULA_ETC`
    if [ $USER -ne 0 ]; then
        log_error "User ID is not set correctly in the $BACULA_ETC directory."
        exit_code=1
    else
        log_info "User ID is set properly."
    fi

    GROUP=`stat --format="%g" $BACULA_ETC`
    if [ $GROUP -ne 0 ]; then
        log_error "Group ID is not set correctly in the $BACULA_ETC directory."
        exit_code=1
    else
        log_info "Group ID is set properly in the $BACULA_ETC directory."
    fi

    log_info "Check whether the $BACULA_ETC directory has the correct access rights."
    PRIV=`stat --format="%a" $BACULA_ETC`
    if [ $PRIV -ne 755 ]; then
        log_error "The access rights are not set correctly in the $BACULA_ETC directory."
        exit_code=1
    else
        log_info "The access rights are set properly in the $BACULA_ETC directory."
    fi
fi

if [ -f "$BACULA_CONF" ]; then
    log_info "Check whether the $BACULA_CONF and $BACULA_SQL files are owned by the Bacula group."
    GROUP=`stat --format="%G" $BACULA_CONF`
    if [ x"$GROUP" != "xbacula" ]; then
        log_error "The $BACULA_CONF file has to be owned by the Bacula group."
        exit_code=1
    else
        log_info "The $BACULA_CONF file is owned by the Bacula group."
    fi
fi

if [ -f $BACULA_SQL ]; then
    GROUP=`stat --format="%G" $BACULA_SQL`
    if [ x"$GROUP" != "xbacula" ]; then
        log_error "The $BACULA_SQL file has to be owned by the Bacula group."
        exit_code=1
    else
        log_info "The $BACULA_SQL file is owned by the Bacula group."
    fi
fi


log_info "Check whether all files have proper access right in the $BACULA_ETC directory."
FILES=`ls -1 $BACULA_ETC/*`
for file in $FILES
do
    PRIV=`stat --format="%a" $file`
    if [ $PRIV -ne 640 ]; then
        log_error "The access rights are not set correctly on the $file file."
        exit_code=1
    else
        log_info "The access rights are set properly on the $file file."
    fi
done

if [ $exit_code -eq 1 ]; then
    mkdir -p $POSTUPGRADE_DIR/bacula
    cp postupgrade.d/bacula_script.sh $POSTUPGRADE_DIR/bacula/bacula_script.sh
    chmod a+x $POSTUPGRADE_DIR/bacula/bacula_script.sh
    exit_fail
fi
exit_pass 
