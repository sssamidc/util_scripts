#!/usr/bin/bash

cmd=/usr/bin/systemd-analyze
#kern=`${cmd} | grep ^Start | awk -F' ' '{ print $10 }'`
# echo 
# kerntime=`${kern} | grep -Eo '[0-9]+\.[0-9]+'`
# echo ${kerntime}

## Working on my system
## TODO
kernel=`${cmd} | grep ^Start | awk -F'+' '{a=$3; print a}' | awk -F' ' '{if($2=="(kernel)")print $1}' | grep -Eo '[0-9]+\.[0-9]+'`
uspace=`${cmd} | grep ^Start | awk -F'+' '{a=$4; print a}' | awk -F' ' '{if($2=="(userspace)")print $1}' | grep -Eo '[0-9]+\.[0-9]+'`

# Debug
echo ${kernel}
echo ${uspace}
