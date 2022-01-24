# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
<<<<<<< HEAD
=======
## [0.8.1] - 2019-02-21
### Fixed
- Fixed front end to allow PPN control to remain blank

## [0.8.0] - 2019-01-31
### Added
- Added controls for using external license servers

## [0.7.4] - 2018-01-08
### Fixed
- Fixed bug caused by attempting to assign to an attr_reader

## [0.7.3] - 2019-01-24
### Fixed
- Fixed bug when entering a blank PPN request

## [0.7.2] - 2019-01-09
### Changed
- Requesting a hugemem node always requests the entire node

## [0.7.1] - 2019-01-08
### Fixed
- Fixed bug when entering a blank PPN request

## [0.7.0] - 2019-01-08
### Added 
- Added a control to select number of cores

### Changed
- Fixed bug where hugemem nodes did not get access to all 48 processors

## [0.6.0] - 2018-07-26
### Changed
- Fixed bug where ANSYS parallel licenses were not properly reserved at submission time.
    [#15](https://github.com/OSC/bc_osc_ansys_workbench/issues/15)
>>>>>>> 0b22f33afb5ec98598a4f6d812b75660dd45a892

## [0.5.0] - 2018-03-27
### Changed
- Switched from using Fluxbox to Xfce for the window manager.
  [#13](https://github.com/OSC/bc_osc_ansys_workbench/issues/13)

## [0.4.0] - 2018-03-13
### Changed
- Changed from Oakley cluster to Owens cluster.
- Changed "Account" label to "Project" in the form.

### Fixed
- Fixed CFX and Fluent parallel solvers (now properly use `pbs_mom`).

## [0.3.0] - 2018-02-26
### Added
- Added ANSYS 17.2 as an option.
- Added warning for using older versions.

## [0.2.0] - 2018-01-03
### Added
- Added ANSYS 18.1 as an option.
  [#6](https://github.com/OSC/bc_osc_ansys_workbench/issues/6)

### Changed
- Modified the `CHANGELOG.md` formatting.
- Refactored to use new Dashboard ERB templating.
  [#3](https://github.com/OSC/bc_osc_ansys_workbench/issues/3)
- Updated date in `LICENSE.txt`.

## [0.1.0] - 2017-06-14
### Changed
- Refactored for the new Batch Connect app.

## [0.0.7] - 2017-05-15
### Fixed
- Future-proof Fluxbox configuration.

## [0.0.6] - 2017-05-12
### Changed
- Remove FVWM and added Fluxbox as the window manager.

## [0.0.5] - 2017-04-24
### Changed
- Version assets removing need for `bin/setup`.

## [0.0.4] - 2017-04-21
### Added
- Added `bin/setup` script for easier deployment.

## [0.0.3] - 2017-03-22
### Fixed
- Set working directory to `$HOME` for FVWM as well.
- Add quotes around paths.

## [0.0.2] - 2017-03-22
### Fixed
- Specify gpus when requesting `vis` node.
- Set working directory to `$HOME`.

## 0.0.1 - 2016-12-20
### Added
- Initial release!

<<<<<<< HEAD
[Unreleased]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.5.0...HEAD
=======
[Unreleased]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.8.1...HEAD
[0.8.1]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.8.0...v0.8.1`
[0.8.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.7.4...v0.8.0
[0.7.4]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.5.0...v0.6.0
>>>>>>> 0b22f33afb5ec98598a4f6d812b75660dd45a892
[0.5.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.0.7...v0.1.0
[0.0.7]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/OSC/bc_osc_ansys_workbench/compare/v0.0.1...v0.0.2
