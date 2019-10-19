# ChangeLog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](KeepAChangelog) and this project
adheres to [Semantic Versioning](Semver).

## [Unreleased]

- Your contribution here!
- Pipe captured bytes to the STDOUT stream

## [0.0.4] - 2019-10-20
### Changed
- Update Xcode project settings to 11.1 (11A1027)
- Add Info.plist to project and target for Catalina compatability

## [0.0.3] - 2016-07-11
### Changed
- Ctrl+c cancels capturing, (-t, recordingDuration now optional)
- refactor constants to Constants.h/m

### Added
- main.m for C code (including signal handler)
- message in console when capturing starts

## [0.0.2] - 2016-07-08
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

[Unreleased]: https://github.com/matthutchinson/videosnap/compare/v0.0.4...HEAD
[0.0.4]: https://github.com/matthutchinson/videosnap/compare/v0.0.3...v0.0.4
[0.0.3]: https://github.com/matthutchinson/videosnap/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/matthutchinson/videosnap/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/matthutchinson/videosnap/releases/tag/v0.0.1
[KeepAChangelog]: http://keepachangelog.com/en/1.0.0/
[Semver]: http://semver.org/spec/v2.0.0.html
