# [WIP] Batch Connect - CHPC Example Shiny App

![GitHub Release](https://img.shields.io/github/release/osc/bc_osc_example_shiny.svg)
[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)

A Batch Connect app designed for Open OnDemand that launches a Shiny App on 
CHPC clusters.

## Prerequisites

This Batch Connect app requires the following software be installed on the
**compute nodes** that the batch job is intended to run on (**NOT** the
OnDemand node):

- [Shiny] x.y.z+
- [Lmod] 6.0.1+ or any other `module purge` and `module load <modules>` based
  CLI used to load appropriate environments within the batch job

[Shiny]: https://shiny.rstudio.com/
[Lmod]: https://www.tacc.utexas.edu/research-development/tacc-projects/lmod

## Install

Use git to clone this app and checkout the desired branch/version you want to
use:

```sh
scl enable git19 -- git clone <repo>
cd <dir>
scl enable git19 -- git checkout <tag/branch>
```

You will not need to do anything beyond this as all necessary assets are
installed. You will also not need to restart this app as it isn't a Passenger
app.

To update the app you would:

```sh
cd <dir>
scl enable git19 -- git fetch
scl enable git19 -- git checkout <tag/branch>
```

Again, you do not need to restart the app as it isn't a Passenger app.

## Contributing

1. Fork it ( https://github.com/OSC/bc_osc_example_shiny/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## CHPC's notes

### Function overview

* Uses CHPC's R (3.6.1) which has shiny installed
* To run a webserver, use an openresty container running nginx
* The script.sh that launches the OOD app creates a nginx config file and Shiny app launcher, then runs R with the launcher, followed by looking for the Unix socket created by the R's Shiny, thich then gets used by the nginx startup
* The user shiny app path is specified in the job specs' input box
* Currently does not run on Friscos due to technical limitations

Note that Shiny app can be also launched from the OOD's RStudio app by typing
library('shiny')
runApp("newdir") - where "newdir" is the directory where app.R resides


