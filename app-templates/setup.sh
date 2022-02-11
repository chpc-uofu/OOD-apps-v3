#!/bin/bash

# need to run as root

TEMPLDIR=/var/www/ood/apps/templates
if [[ ! -d $TEMPLDIR ]]; then
  mkdir $TEMPLDIR
fi
cd $TEMPLDIR

ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/clusters .
ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/genmodulefiles.sh .
ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/getmodules.sh .
ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/interactives .
ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/job_params .
ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/app-templates/job_params.basic .

./genmodulefiles.sh
