#!/bin/bash


. /usr/share/preupgrade/common.sh
check_applies_to ""  "cp,grep"
switch_to_content
#END GENERATED SECTION

[ ! -r cansave ] && log_error generic Part of the content is missing! && \
  exit $RESULT_ERROR

found=0
#Some of the package have the same version (tarball) in RHEL 6 and RHEL 7.
#Therefore we can store their modified configuration files safely.
while read i
do
  #skip non-rh and unavailable packages
  grep -q "^$i[[:space:]]" $VALUE_RPM_QA && is_dist_native "$i" || continue

  #copy the modified /etc/ located files to the preupgrade destination directory
  for j in $(rpm -ql $i | grep ^/etc/)
  do
    grep " $j$" $VALUE_CONFIGCHANGED >/dev/null && \
      cp --parents -a "$j" "$VALUE_TMP_PREUPGRADE"/cleanconf/ && \
      log_info $i "user modified config file $j stored" && found=1
  done
done < cansave

[ $found -eq 1 ] && exit $RESULT_FIXED

exit $RESULT_PASS