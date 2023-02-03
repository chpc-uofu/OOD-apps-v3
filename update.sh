#!/bin/bash

# this script needs to run as root

APPS="abaqus_app ansysedt_app ansys_workbench_app chpc-systemstatus codeserver_app comsol_app coot_app csd_app desktop_basic desktop_expert idl_app idv_app jupyter_app lumerical_app mathematica_app matlab_app matlab_html_app meshroom_app paraview_app relion_app rstudio_server_app sas_app shiny_app stata_app vmd_app"
DATE=`date +%Y-%m-%d`
BAKDIR="/var/www/ood/apps/sys-$DATE"

cd /var/www/ood/apps/sys
if [[ ! -d $BAKDIR ]]; then
  mkdir -p $BAKDIR
fi

for APP in $APPS
do
  echo Updating $APP
  mv /var/www/ood/apps/sys/$APP $BAKDIR
  ln -s /uufs/chpc.utah.edu/sys/ondemand/chpc-apps/$APP .
done
