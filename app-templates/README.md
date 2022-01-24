Templates and scripts for OOD app job parameters

Two scripts for module list generation:
- getmodules.sh - generates a terse list of module versions that can be run from the ERB files - BUT, these are refreshed constantly and create an unacceptable load on the OOD server
- genmodulefiles.sh - workaround to generate static text files with module versions, can be run from a cron job


