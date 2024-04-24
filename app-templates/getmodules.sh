#!/bin/bash
# call as getmodules.sh module_name

# no Lmod in non-interactive shell, so need to source it
source /uufs/chpc.utah.edu/sys/etc/profile.d/module.sh
$LMOD_DIR/spider -o spider-json $MODULEPATH > /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/modules/notchpeak.json
