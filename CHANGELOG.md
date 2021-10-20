# ChangeLog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](KeepAChangelog) and this project
adheres to [Semantic Versioning](Semver).

## [Unreleased]

- Your contribution here!

## [0.0.7] - 2020-Oct-19
### Added
- Fix issues with connected iOS device discovery and build/test on M1 arch

### Changed
- Min version off macOS is 10.9
- Minor changes to printHelp and man page copy
- Device discovery using run loop to wait/wake up connected devices
- Updated release scheme to work with package building/notarizing and stapling
  (see
  [here](https://scriptingosx.com/2021/07/notarize-a-command-line-tool-with-notarytool/) for details)

## [0.0.5] - 2020-Aug-24
### Added
- Supports recording from any attached iOS device

### Changed
- Info.plist now [embedded into binary](https://red-sweater.com/blog/2083/the-power-of-plist)
- Updated project file and build settings for latest Xcode

## [0.0.4] - 2019-Oct-20
### Changed
- Update Xcode project settings to 11.1 (11A1027)
- Add Info.plist to project and target for Catalina compatability

## [0.0.3] - 2016-Jul-11
### Changed
- Ctrl+c cancels capturing, (-t, recordingDuration now optional)
- refactor constants to Constants.h/m

### Added
- main.m for C code (including signal handler)
- message in console when capturing starts

## [0.0.2] - 2016-Jul-08
### Changed
- Use the [AV Foundation](https://developer.apple.com/av-foundation/) framework
- Encoding presets changed, use `-p` option to set (`-s` option dropped)

### Added
- New encoding presets are: High, Medium (default), Low, 640x480 or 1280x720

### Removed
- Cocoa and QTKit frameworks dropped

## [0.0.1] - 2013-09-08
### Changed
- Initial release (using the QTKit framework)

[Unreleased]: https://github.com/matthutchinson/videosnap/compare/v0.0.7...HEAD
[0.0.7]: https://github.com/matthutchinson/videosnap/compare/v0.0.5...v0.0.7
[0.0.5]: https://github.com/matthutchinson/videosnap/compare/v0.0.4...v0.0.5
[0.0.4]: https://github.com/matthutchinson/videosnap/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/matthutchinson/videosnap/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/matthutchinson/videosnap/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/matthutchinson/videosnap/releases/tag/v0.0.1
[KeepAChangelog]: http://keepachangelog.com/en/1.0.0/
[Semver]: http://semver.org/spec/v2.0.0.html
