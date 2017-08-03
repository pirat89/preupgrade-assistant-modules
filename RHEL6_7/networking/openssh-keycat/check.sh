#!/bin/bash
. /usr/share/preupgrade/common.sh

#END GENERATED SECTION

grep -E "^\s*AuthorizedKeysCommand /usr/libexec/openssh/ssh-keycat" /etc/ssh/sshd_config

[[ $? -ne 0 ]] && {
  log_medium_risk "The ssh-keycat files are moved to openssh-keycat."
  echo "The following ssh-keycat files are moved to a new package 'openssh-keycat':
/etc/pam.d/ssh-keycat
/usr/libexec/openssh/ssh-keycat
/usr/share/doc/openssh-server-5.3p1/HOWTO.ssh-keycat

If you want ssh-keycat, you need to install the openssh-keycat package.
" >> solution.txt
  exit $RESULT_FAIL
}


log_slight_risk "ssh-keycat is used as a part of the openssh-keycat package in Red Hat Enterprise Linux 7."
echo "ssh-keycat is moved to its own openssh-keycat package, which
is automatically installed by the postupgrade script.
" >> solution.txt

cp install-openssh-keycat.sh $POSTUPGRADE_DIR/install-openssh-keycat.sh
exit $RESULT_FIXED

