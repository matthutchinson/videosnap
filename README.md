# VideoSnap

VideoSnap is an OSX command line tool for recording video and audio from any
attached capture device.

You can specify which device to capture from, the duration, encoding, a delay
period (before capturing starts) and optionally turn off audio capturing.

By default VideoSnap will capture 6 seconds of video and audio from the default
capture device at 30fps, with a Medium encoding preset and a short (0.5 second)
warm-up delay.

You can also use VideoSnap to list all attached capture devices by name.

## Requirements

 * OSX 10.7+ (x86_64)
 * A web cam

If you need to capture video on older versions of OSX (or on 32-bit hardware),
try [wacaw](http://webcam-tools.sourceforge.net).

## Usage

The following options are available:

```
  -l    List attached capture devices
  -t    Set duration of video (in seconds, default 6s)
  -w    Set delay before capturing starts (in seconds, default 0.5s)
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

Capture 1 minute of video (Medium preset), but no audio from the "Built-in
iSight" device, delaying for 5 secs, saving to my_video.mov

    videosnap -t 60 -w 5 -d 'Built-in iSight' --no-audio my_video.mov

List all attached devices by name

    videosnap -l

### Warming Up

Since some camera hardware can take a while to warm up, a default delay of 0.5
seconds is applied. Override this with the `-w` argument (0 meaning no delay).

### Encoding Presets

The AVFoundation framework provides the following video encoding presets:

| Resolution    | Comments                                                  |
| ------------- | --------------------------------------------------------- |
| High          | Highest recording quality. This varies per device.        |
| Medium        | Suitable for Wi-Fi sharing. The actual values may change. |
| Low           | Suitable for 3G sharing. The actual values may change.    |
| 640x480       | VGA.                                                      |
| 1280x720      | 720p HD.                                                  |

Use the `-p` flag to set which preset to apply.

## Help

Get command help with:

    videosnap -h

If you have any problems, please do [raise an
issue](https://github.com/matthutchinson/videosnap/issues) on GitHub. When
reporting a bug, remember to mention what platform and hardware you are using
and the steps I can take to reproduce the issue.

## Contributing

Bug [reports](https://github.com/matthutchinson/videosnap/issues) and [pull
requests](https://github.com/matthutchinson/videosnap/pulls) are welcome on
GitHub. Before submitting pull requests, please read the [contributing
guidelines](https://github.com/matthutchinson/lifx_dash/blob/master/CONTRIBUTING.md)
for more details.

## Development

VideoSnap is coded with Objective-C and uses the
[AVFoundation](https://developer.apple.com/av-foundation/) framework. You can
build the project with [Xcode](http://developer.apple.com/xcode/) (using the
Xcode project workspace in the repository, or with the `xcodebuild` command).

# Future Work

* Allow VideoSnap to pipe captured bytes to the STDOUT stream
* Submit VideoSnap as a package for [Homebrew](http://brew.sh)
* Default filename should include a timestamp of when recording began
* Allow more size/quality options for video and/or audio
* Allow VideoSnap to capture a single frame to an image file (with compression
  options based on file type like [ImageSnap](https://github.com/rharder/imagesnap))
* A comprehensive test suite in Xcode

## License

VideoSnap is distributed under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

## Who's Who?

* [VideoSnap](http://github.com/matthutchinson/videosnap) by [Matthew Hutchinson](http://matthewhutchinson.net)
* Inspired by [ImageSnap](https://github.com/rharder/imagesnap) by [@rharder](https://github.com/rharder)
