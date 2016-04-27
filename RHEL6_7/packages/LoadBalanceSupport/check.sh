#!/bin/bash

. /usr/share/preupgrade/common.sh

#END GENERATED SECTION

check_root

if [ -z "$SOLUTION_FILE" ]; then
  cat /dev/null > ./solution.txt
  SOLUTION_FILE="./solution.txt"
fi


declare -a new_lb_check=$(get_dist_native_list | egrep '^(keepalived|haproxy|piranha|ipvsadm)$')

if [[ "${new_lb_check[@]}" =~ "ipvsadm" ]];then
  if [[ "${new_lb_check[@]}" =~ "piranha" ]];then
     echo "You have installed piranha package on your system. This is no longer supported load balancer 
solution. For RHEl 7 compatible load balancer support install keepalived and haproxy packages" >> $SOLUTION_FILE
     log_high_risk "For RHEl 7 compatible load balancer support run 'yum install keepalived haproxy'"
     exit_fail
  else
     if [[ "${new_lb_check[@]}" =~ "keepalived" ]] && [[ "${new_lb_check[@]}" =~ "haproxy" ]];then
       echo "Load balancer support on this system is fully compatible with RHEL 7" >> $SOLUTION_FILE
       exit_pass
     elif [[ "${new_lb_check[@]}" =~ "keepalived" ]] ;then
       echo "Your system has full support for RHEL 7 compatible LVS based load balancer. For tcp/http based load balancer and proxy install haproxy package " >> $SOLUTION_FILE
       log_none_risk "For tcp/http based load balancer and proxy run 'yum install haproxy'"
       exit_informational
     elif [[ "${new_lb_check[@]}" =~ "haproxy" ]] ;then
       echo "You have installed haproxy tcp/http based load balancer and proxy. You have installed ipvsadm LVS based load balancer,if you want to implement additional layer for health check and failover handling, install keepalived package" >> $SOLUTION_FILE
       log_none_risk "For for health check and failover handling of your LVS based load balancer run 'yum install keepalived'"
       exit_informational
     else
       echo "You have installed ipvsadm LVS based load balancer,if you want to implement additional layer for health check and failover handling, install keepalived package. You can install haproxy package for tcp/http based load balancer and proxy" >> $SOLUTION_FILE
       log_none_risk "For health check and failover handling run 'yum install keepalived' for tcp/http based load balancer and proxy 'yum install haproxy'"
       exit_informational
     fi
  fi
elif [[ "${new_lb_check[@]}" =~ "haproxy" ]] ;then
  echo "You have installed haproxy tcp/http based load balancer and proxy. If you want to implement also LVS based load balancer, install ipvsadm and keepalived packages" >> $SOLUTION_FILE  
  log_none_risk "For LVS based Load Balancer run 'yum install ipvsadm keepalived'"
  exit_informational
else

   exit_pass
fi