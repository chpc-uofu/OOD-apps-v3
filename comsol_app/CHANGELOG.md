# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [0.5.2] - 2019-02-21
### Fixed
- Fixed bug caused by attempting to assign to attr_reader
- Fixed front end to allow ppn control to remain blank

## [0.5.1] - 2019-01-09
### Changed
- Changed hugemem to always request a full node

## [0.5.0] - 2019-01-09
### Added
- Added control to request number of CPUs

## [0.4.0] - 2018-10-22
### Added
- Added COMSOL 5.4 to the app.

## [0.3.0] - 2018-03-21
### Added
- Added COMSOL 5.3a to the app.

### Changed
- Modified the `CHANGELOG.md` formatting.
- Updated the date in `LICENSE.txt`.
- Changed the product icon.
- Refactored to use the new Dashboard ERB templating.
  [#4](https://github.com/OSC/bc_osc_comsol/issues/4)
- Switched from using Fluxbox to Xfce for the window manager.

### Fixed
- Fixed local configuration not always being ignored.

## [0.2.0] - 2017-12-15
### Changed
- Updated to run jobs on Owens cluster.

## [0.1.1] - 2017-06-23
### Added
- Added support for COMSOL 5.3 on Oakley.
  [#3](https://github.com/OSC/bc_osc_comsol/issues/3)

## [0.1.0] - 2017-06-14
### Changed
- Refactored for the new Batch Connect app.

## [0.0.8] - 2017-05-15
### Changed
- Future-proof fluxbox configuration.

## [0.0.7] - 2017-05-12
### Changed
- Remove FVWM and added Fluxbox as the window manager.

## [0.0.6] - 2017-04-24
### Changed
- Version assets removing need for `bin/setup`.

## [0.0.5] - 2017-04-21
### Added
- Added `bin/setup` script for easier deployment.

## [0.0.4] - 2017-03-22
### Fixed
- Set working directory to `$HOME` for FVWM as well

## [0.0.3] - 2017-03-22
### Fixed
- Specify gpus when requesting `vis` node.
- Set working directory to `$HOME`.

## [0.0.2] - 2017-01-10
### Added
- Added more versions of COMSOL.

## 0.0.1 - 2016-12-20
### Added
- Initial release!

[Unreleased]: https://github.com/OSC/bc_osc_comsol/compare/v0.5.2...HEAD
[0.5.2]: https://github.com/OSC/bc_osc_comsol/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/OSC/bc_osc_comsol/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/OSC/bc_osc_comsol/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/OSC/bc_osc_comsol/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/OSC/bc_osc_comsol/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/OSC/bc_osc_comsol/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/OSC/bc_osc_comsol/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.8...v0.1.0
[0.0.8]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.7...v0.0.8
[0.0.7]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/OSC/bc_osc_comsol/compare/v0.0.1...v0.0.2
