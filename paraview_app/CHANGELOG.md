# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2018-03-28
### Changed
- Changed "Account" label to "Project" in the form.
- Updated the date in `LICENSE.txt`.
- Changed the product icon.
- Refactored to use the new Dashboard ERB templating.
  [#7](https://github.com/OSC/bc_osc_paraview/issues/7)
- Switched from using Fluxbox to Xfce for the window manager.

### Fixed
- Fixed local configuration not always being ignored.

## [0.2.0] - 2017-10-30
### Changed
- Changed the `CHANGELOG.md` formatting.
- Refactored to take advantage of new ERB templating in Dashboard plugin code.
- Now uses Owens node instead of Oakley.

### Fixed
- Fixed capitalization of ParaView name.
  [#8](https://github.com/OSC/bc_osc_paraview/pull/8)

## [0.1.0] - 2017-06-14
### Changed
- Refactored for the new Batch Connect app.

## [0.0.7] - 2017-05-15
### Fixed
- Future-proof fluxbox configuration.

## [0.0.6] - 2017-05-12
### Added
- Added an optional input file environment variable.

### Changed
- Remove FVWM and added Fluxbox as the window manager.

## [0.0.5] - 2017-04-24
### Changed
- Version assets removing need for `bin/setup`.

## [0.0.4] - 2017-04-21
### Added
- Added `bin/setup` script for easier deployment.

### Fixed
- Sanitize module environment before loading GUI.

## [0.0.3] - 2017-03-22
### Fixed
- Set working directory to `$HOME` for FVWM as well.

## [0.0.2] - 2017-03-22
### Fixed
- Fixed `template` directory being ignored by bower.
- Set working directory to `$HOME`.

## 0.0.1 - 2016-12-20
### Added
- Initial release!

[Unreleased]: https://github.com/OSC/bc_osc_paraview/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/OSC/bc_osc_paraview/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/OSC/bc_osc_paraview/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/OSC/bc_osc_paraview/compare/v0.0.7...v0.1.0
[0.0.7]: https://github.com/OSC/bc_osc_paraview/compare/v0.0.6...v0.0.7
[0.0.6]: https://github.com/OSC/bc_osc_paraview/compare/v0.0.5...v0.0.6
[0.0.5]: https://github.com/OSC/bc_osc_paraview/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/OSC/bc_osc_paraview/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/OSC/bc_osc_paraview/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/OSC/bc_osc_paraview/compare/v0.0.1...v0.0.2
