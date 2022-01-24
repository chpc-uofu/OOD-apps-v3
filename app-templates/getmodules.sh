#!/bin/bash
# call as getmodules.sh module_name

# no Lmod in non-interactive shell, so need to source it
source /uufs/chpc.utah.edu/sys/etc/profile.d/module.sh
module -t spider $1 2>&1
