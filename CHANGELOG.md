### VideoSnap Change Log

All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning][Semver].

## [Unreleased]

  * WIP - allow VideoSnap to pipe captured bytes to the STDOUT stream

## [0.0.3][] (11 July 2016)
  * Ctrl+c cancels capturing, (-t, recordingDuration now optional)
  * refactor constants to Constants.h/m
  * added main.m for C code (including signal handler)
  * show message in console when capturing starts

## [0.0.2][] (8 July 2016)
  * Update to use the [AV Foundation](https://developer.apple.com/av-foundation/) framework
  * Cocoa and QTKit frameworks dropped
  * Encoding presets changed, use `-p` option to set (`-s` option dropped)
  * New encoding presets are: High, Medium (default), Low, 640x480 or 1280x720

## [0.0.1][] (8 September 2013)
  * Initial release of VideoSnap (using the QTKit framework)

[Unreleased]: https://github.com/matthutchinson/videosnap/compare/v0.0.3...HEAD
[0.0.3]: https://github.com/matthutchinson/videosnap/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/matthutchinson/videosnap/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/matthutchinson/videosnap/releases/tag/v0.0.1
[Semver]: http://semver.org
