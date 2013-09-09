# VideoSnap

VideoSnap is an OSX command line tool for recording video and audio from any
attached QuickTime capture device.

You can specify which device to capture from, the duration, size/quality, a
delay period (before capturing starts) and optionally turn off audio capturing.

The only _required_ argument is a file path. By default VideoSnap will capture 6
seconds of video and audio from the default capture device in H.264(SD480)/AAC
encoding to 'movie.mov'. You can also use VideoSnap to list attached QuickTime
capture devices by name.

This command was inspired by [ImageSnap](https://github.com/rharder/imagesnap)
from [@rharder](https://github.com/rharder), and driven by problems with the
older (carbon based) [wacaw](http://webcam-tools.sourceforge.net) command
(which no longer works with some of the latest Mac/OSX hardware).

## Usage

The following options are available:

```
  -l    List attached QuickTime capture devices
  -t    Set duration of video (in seconds, default 6s)
  -w    Set delay before capturing starts (in seconds, default 0s)
  -d    Set the capture device by name (use -l to list attached devices)
  -s    Set the H.264 video size/quality (use 120, 240, SD480 (default) HD720)
  -v    Turn ON verbose mode (OFF by default)
  -h    Show help
  --no-audio
        Don't capture audio (audio IS captured by default)
```

### Examples

It's hard to show a screencast of VideoSnap in action so I've recorded an
[ascii.io](http://ascii.io/a/5358) video instead! Or follow along with the
examples below;

Capture 10.75 secs of video in 720HD format to movie.mov

    videosnap -t 10.75 -s 'HD720'

Capture 1 minute of SD480 video (default), but no audio from the
"Built-in iSight" device, delaying for 5 secs, saving to my_video.mov

    videosnap -t 60 -w 5 -d 'Built-in iSight' --no-audio my_video.mov

## Compatibility

VideoSnap is OSX only, and should work without any issues on OSX 10.5+.
If you do run into problems with the command, please [report an
issue](https://github.com/matthutchinson/videosnap/issues).

## Contibuting

If you would like to suggest a feature or report a bug, please use [GitHub
issues](https://github.com/matthutchinson/videosnap/issues) and if possible
(fork the project) and submit a pull-request. When reporting a bug, please
clearly indicate what platform and hardware you are running and the steps I
should take to reproduce the issue.

## Development

VideoSnap is coded with Objective-C and uses the
[Cocoa](https://developer.apple.com/technologies/mac/cocoa.html) and
[QTKit](https://developer.apple.com/quicktime/) frameworks to capture video.
You can build the project with [Xcode](http://developer.apple.com/xcode/)
(using the Xcode project in the repository, or via the command line with
`xcodebuild`)

## License

VideoSnap is distributed with The [MIT
License](https://github.com/matthutchinson/videosnap/blob/master/LICENSE.md)
(MIT).

## Ideas

* Submit VideoSnap as a package for [Homebrew](http://brew.sh)
* Default filename should include a time stamp of when recording began
* Allow more size/quality options for video and/or audio
* Allow VideoSnap to capture a single frame to an image file (with compression
  options based on file type like [ImageSnap](https://github.com/rharder/imagesnap))
* Add optional window pane showing a CaptureView during recording
* Add a comprehensive test suite in Xcode
* Allow VideoSnap to pipe output video
