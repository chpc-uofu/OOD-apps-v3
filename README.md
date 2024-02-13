# OOD-apps
Repository of CHPC's Open OnDemand apps

Version 3.4
- Dynamic GPU pulldown menu
  - pulldown menu is dynamically updated using account:partition selection
- Dynamic account:partition pulldown menu
  - pulldown menu is dynamically updated using cluster selection
- Universal form.js for all apps
  - all apps use universal form.js, regardless of single/multinode, GPU/non-GPU app
  - refactored JavaScript funtions help performance

Version 3.3
- Advanced options with checkbox
  - all advanced options have their own checkboxes to offer input when checked
  - advanced options is checked if any advanced option is selected
  - added nodelist (sbatch -w), additional environment and constraints (sbatch -C)
- unified form.js and templated submit.yml.erb for 3 types of apps
  - form_params_gpu - Codeserver, CSD, Desktop, IDL, Jupyter, Mathematica, Matlab, Matlab Web, RStudio, SAS, Shiny, StarCCM+, Stata
  - form_params_multinode - Comsol, Lumerical
  - form_params_gpu_multinode - Abaqus, AnsysWB, AnsysEDT, Relion
  - no form_params - just Friscos - Coot, IDV, Meshroom, Paraview, VMD

Version 3.2
- templated submit.yml.erb
- limits to number of CPUs, memory, walltime via form.js

Version 3.1
- advanced options with pull down menu
- pulldown menu for GPUs

Version 3.0
- templated filling of job parameters 
- dynamic filling of application versions (module files)
- the templates are in directory app-templates

This is a repository of interactive apps used at CHPC with Open OnDemand.

Each subdirectory has its own README.md which contains information about this particular app.
