#!/bin/bash

apps=("matlab" "abaqus" "ansysedt" "ansys" "comsol" "idl" "lumerical" "mathematica" "idv" "coot" "vmd" "meshroom" "paraview" "csd")

# no Lmod in non-interactive shell, so need to source it
source /uufs/chpc.utah.edu/sys/etc/profile.d/module.sh

for str in ${apps[@]}; do
  module -t spider $str 2> $str.txt
done



