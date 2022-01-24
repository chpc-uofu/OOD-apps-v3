# Batch Connect - CHPC Matlab web client

An interactive app that launches Matlab web client through the [MATLAB integration for Jupyter](https://github.com/mathworks/jupyter-matlab-proxy).

CHPC implementation is based on that from [Virginia Tech](https://github.com/AdvancedResearchComputing/OnDemandApps/tree/main/bc_vt_matlab_html), with the difference being that the app is not running from a container.

The Matlab integration for Jupyter was installed into an independent miniconda installation as:
```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ./Miniconda3-latest-Linux-x86_64.sh -b -s -p /uufs/chpc.utah.edu/sys/installdir/miniconda3/matlab-web-app
export PATH=/uufs/chpc.utah.edu/sys/installdir/miniconda3/matlab-web-app/bin:$PATH
pip3 install jupyter-matlab-proxy
```

Matlab used is a system-wide installed Matlab.


