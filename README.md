# VideoSnap

VideoSnap is an macOS command line tool for recording video and audio from any
attached capture device (including any attached iOS device).

You can specify which device to capture from, the duration, encoding and a delay
period (before capturing starts). You can also disable audio recording.

By default VideoSnap will capture both video and audio from the default capture
device at 30fps, with a Medium quality preset and a short (0.5s) warm-up delay.

If no duration is specified, VideoSnap will record until you cancel with
[Ctrl+c]. You can also use VideoSnap to list attached capture devices by name.

## Requirements

 * macOS 10.9+ (Intel/M1)
 * A web cam

If you need to capture video on older versions of macOS (e.g. 32-bit) try
[wacaw](http://webcam-tools.sourceforge.net)

## Installation

Download the [latest
release](https://github.com/matthutchinson/videosnap/releases) and run the
installer.

This will copy the binary and man page to your `/usr/local` directory.

## Usage

The following options are available:

```
  -l    List attached capture devices
  -w    Set delay before capturing starts (in seconds, default 0.5s)
  -t    Set duration of video (in seconds)
  -d    Set the capture device by name (use -l to list attached devices)
  -p    Set the encoding preset (use High, Medium (default), Low, 640x480 or 1280x720)
  -v    Turn ON verbose mode (OFF by default)
  -h    Show help
  --no-audio
        Don't capture audio (audio IS captured by default)
```

### Examples

Capture 10.75 secs of video in 1280x720 720p HD format saving to movie.mov

    videosnap -t 10.75 -p '1280x720'

Capture 1 minute of video (Medium preset), but no audio from the "FaceTime HD
Camera (Built-in)" device, delaying for 5 secs, saving to my_video.mov

    videosnap -t 60 -w 5 -d 'FaceTime HD Camera (Built-in)' --no-audio video.mov

List all attached devices by name

    videosnap -l

### Warming Up

Since some camera hardware can take a while to warm up, a default delay of 0.5
seconds is applied. Override this with the `-w` argument (0 meaning no delay).

**NOTE**: Videosnap will also wait 0.5s to allow any connected devices to be
discovered (e.g. for iOS screen capture).

### Encoding Presets

The AVFoundation framework provides the following video encoding presets:

| Resolution    | Comments                                                  |
| ------------- | --------------------------------------------------------- |
| High          | Highest recording quality. This varies per device.        |
| Medium        | Suitable for Wi-Fi sharing. The actual values may change. |
| Low           | Suitable for 3G sharing. The actual values may change.    |
| 640x480       | VGA.                                                      |
| 1280x720      | 720p HD.                                                  |

Use the `-p` flag to choose a preset.

### Capturing from connected iOS devices

It is possible to screen capture video & audio from an attached iOS device. 

For the device to be discovered you must confirm that you 
**Trust This Computer** on the device when it is connected and unlocked.

There are some limitations and issues with iOS screen capturing.

  * (issue) the `--no-audio` flag currently has no effect (workaround: mute the device)
  * (limitation) when capturing, the device will not output any audio (but audio will be recorded to the movie file)
  * (limitation) occasionally the device fails to be discovered, this can happen when
    * another process is already capturing from the device
    * the macOS kernel fails to connect to the DAL assistant to communicate with the virtual capture device

## Help

Get command help with:

    videosnap -h
    # or via the man page with
    man videosnap

If you have any problems, please do [raise an
issue](https://github.com/matthutchinson/videosnap/issues) on GitHub. When
reporting a bug, remember to mention what platform and hardware you are using
and the steps I can take to reproduce the issue.

## Development

I try to keep the project up to date with the latest general XCode release.

After opening `videosnap.xcodeproj`, you can set the arguments passed to the
command when it runs in XCode, simply edit the `Run` action in the default
`videosnap` Scheme. (Product -> Scheme -> Edit Scheme...)

You can also build the project from the command line. After cloning run:

```
  xcodebuild clean install
  # you'll find the build executable at
  ./build/Debug/videosnap
  # which symlinks to here
  ./build/pkgroot/usr/local/bin/videosnap
```

If you see this message:

    xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory "..."

Try this to fix your environment:

    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

## Contributing

Bug [reports](https://github.com/matthutchinson/videosnap/issues) and [pull
requests](https://github.com/matthutchinson/videosnap/pulls) are welcome on
GitHub. Before submitting pull requests, please read the [contributing
guidelines](https://github.com/matthutchinson/videosnap/blob/master/CONTRIBUTING.md)
for more details.

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
[here](https://github.com/matthutchinson/videosnap/blob/master/CODE_OF_CONDUCT.md)
for more details.

## Development

VideoSnap is coded with Objective-C and uses the
[AVFoundation](https://developer.apple.com/av-foundation/) framework. You can
build the project with [Xcode](http://developer.apple.com/xcode/) (using the
Xcode project workspace in the repository, or with the `xcodebuild` command).

## Future Work

Work in progress is usually mentioned at the top of the
[CHANGELOG](https://github.com/matthutchinson/videosnap/blob/master/CHANGELOG.md).
If you'd like to get involved in contributing, here are some ideas:

* Allow VideoSnap to pipe captured bytes to the STDOUT stream
* Submit VideoSnap as a package for [Homebrew](http://brew.sh)
* Default filename should include a timestamp of when recording began
* Allow more size/quality options for video and/or audio
* Smile detection while capturing video/image, determine a happiness factor/score
* Allow VideoSnap to capture a single frame to an image file (with compression
  options based on file type like [ImageSnap](https://github.com/rharder/imagesnap))
* A comprehensive test suite

## License

VideoSnap is distributed under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

## Who's Who?

* [VideoSnap](http://github.com/matthutchinson/videosnap) by [Matthew Hutchinson](http://matthewhutchinson.net)
* Inspired by [ImageSnap](https://github.com/rharder/imagesnap) by [@rharder](https://github.com/rharder)
