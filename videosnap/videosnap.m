//
//  VideoSnap.m
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2016 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"

@implementation VideoSnap

- (id)init {
  self = [super init];
  return self;
}


/**
 * return an array of attached AVCaptureDevices
 */
+ (NSArray *)videoDevices {
  NSMutableArray *devices = [NSMutableArray arrayWithCapacity:1];
  [devices addObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]];
  [devices addObjectsFromArray:[AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed]];

  return devices;
}


/**
 * returns the default AVCaptureDevice or nil
 */
+ (AVCaptureDevice *)defaultDevice {
  AVCaptureDevice *device = nil;
  device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  if (device == nil) {
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeMuxed];
  }

  return device;
}


/**
 * returns a AVCaptureDevice matching the name or nil
 */
+ (AVCaptureDevice *)deviceNamed:(NSString *)name {
  AVCaptureDevice *device = nil;
  NSArray *devices = [VideoSnap videoDevices];
  for (AVCaptureDevice *thisDevice in devices) {
    if ([name isEqualToString:[thisDevice description]]) {
      device = thisDevice;
    }
  }

  return device;
}


/**
 * start capturing video (after withDelay) writing toFile for withDuration
 */
+ (BOOL)captureVideo:(AVCaptureDevice *)device
            filePath:(NSString *)filePath
   recordingDuration:(NSNumber *)recordingDuration
           videoPreset:(NSString *)videoPreset
           withDelay:(NSNumber *)delaySeconds
             noAudio:(BOOL)noAudio {

  // create an instance of VideoSnap and start the capture session
  VideoSnap *videoSnap;
  videoSnap = [[VideoSnap alloc] init];

  return [videoSnap startSession:device
                        filePath:filePath
               recordingDuration:recordingDuration
                       videoPreset:videoPreset
                       withDelay:delaySeconds
                         noAudio:noAudio];
}


/**
 * start a capture session on a device, saving to filePath for recordSeconds
 */
- (BOOL)startSession:(AVCaptureDevice *)videoDevice
            filePath:(NSString *)filePath
   recordingDuration:(NSNumber *)recordingDuration
           videoPreset:(NSString *)videoPreset
           withDelay:(NSNumber *)delaySeconds
             noAudio:(BOOL)noAudio {

  BOOL success = NO;
  NSError *nserror;

	verbose("(initializing capture session)\n");
  session = [[AVCaptureSession alloc] init];

	// add video input
	verbose("(adding video device)\n");
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&nserror];

	if (videoInput) {
		if ([session canAddInput:videoInput]) {
			[session addInput:videoInput];
		} else {
			error("Could not add the video device to the session\n");
			return success;
		}

		// add audio input (unless noAudio)
		if (!noAudio) {
		  [self addAudioDevice:videoDevice];
		}

		verbose("(adding movie file output)\n");
		movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];

		// set capture frame rate
		int32_t fps = [CAPTURE_FRAMES_PER_SECOND intValue];
		verbose("(set capture framerate to %i fps)\n", fps);
		AVCaptureConnection *conn = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
		if([conn isVideoMinFrameDurationSupported]) {
			conn.videoMinFrameDuration = CMTimeMake(1, fps);
		}
		if([conn isVideoMaxFrameDurationSupported]) {
			conn.videoMaxFrameDuration = CMTimeMake(1, fps);
		}

		CMTime maxDuration = CMTimeMakeWithSeconds([recordingDuration floatValue], [CAPTURE_FRAMES_PER_SECOND intValue]);
		// set max duration and min free space in bytes before recording can start
		movieFileOutput.maxRecordedDuration = maxDuration;
		movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;

		if ([session canAddOutput:movieFileOutput]) {
			[session addOutput:movieFileOutput];
		} else {
			error("Could not add file '%s' as output to the capture session\n", [filePath UTF8String]);
			return success;
		}

		verbose("(setting video compression)\n");
		
		NSString *capturePreset = [NSString stringWithFormat:@"AVCaptureSessionPreset%@", videoPreset];
		if ([session canSetSessionPreset:capturePreset]) {
			[session setSessionPreset:capturePreset];
	  } else {
			verbose("(could not set compression '%s' for this device, defaulting to Medium)\n", [videoPreset UTF8String]);
			[session setSessionPreset:AVCaptureSessionPresetMedium];
		}

		// delete the target file if it exists
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if([fileManager fileExistsAtPath:filePath]) {
			verbose("(file at '%s' exists, deleting it)\n", [filePath UTF8String]);
			NSError *fileError = nil;

			if (![fileManager removeItemAtPath:filePath error:&fileError]) {
				verbose_error("%s\n", [[fileError localizedDescription] UTF8String]);
				return success;
			}
		}

		// start capture session running
		verbose("(starting capture session)\n");
		[session startRunning];
		if (![session isRunning]) {
			error("Could not start the capture session\n");
			return success;
		}

		// start delay if present
		if ([delaySeconds floatValue] <= 0.0f) {
			verbose("(no delay)\n");
		} else {
			verbose("(delaying for %.2lf seconds)\n", [delaySeconds doubleValue]);
			[[NSRunLoop currentRunLoop] runUntilDate:[[[NSDate alloc] init] dateByAddingTimeInterval: [delaySeconds doubleValue]]];
			verbose("(delay period ended)\n");
		}

		verbose("(starting capture to file at '%s')\n", [filePath UTF8String]);
		[movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:filePath] recordingDelegate:self];
		success = YES;

	} else {
		error("Video device is not connected or available\n");
		verbose_error("%s\n", [[nserror localizedDescription] UTF8String]);
  }

  return success;
}


/**
 * add audio device to a capture session
 */
- (BOOL)addAudioDevice:(AVCaptureDevice *)videoDevice {
  BOOL success = NO;
  NSError *nserror;

  verbose("(adding audio device)\n");
  // if the video device doesn't supply audio, add a default audio device (if possible)
  if (![videoDevice hasMediaType:AVMediaTypeAudio] && ![videoDevice hasMediaType:AVMediaTypeMuxed]) {
		AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&nserror];

		if (audioInput) {
			if ([session canAddInput:audioInput]) {
				[session addInput:audioInput];
				success = YES;
			} else {
				error("Could not add the audio device to the session\n");
			}
		} else {
			error("Audio device is not connected or available\n");
			verbose_error("%s\n", [[nserror localizedDescription] UTF8String]);
		}
  }

	return success;
}


/**
 * delegate called when output file has been written to
 */
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
			fromConnections:(NSArray *)connections
								error:(NSError *)error {

	verbose("(finished writing to movie file)\n");
	BOOL captureSuccessful = YES;

	// check if a problem occurred, to see if recording was successful
	if ([error code] != noErr) {
		id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
		if (value) {
			captureSuccessful = [value boolValue];
		}
	}

	if(captureSuccessful) {
		NSNumber *outputDuration = [NSNumber numberWithFloat: CMTimeGetSeconds([movieFileOutput recordedDuration])];
		console("Captured %.2f seconds of video to '%s'\n", [outputDuration floatValue], [[outputFileURL lastPathComponent] UTF8String]);
	} else {
		error("Could not finalize writing video to file\n");
		error("%s\n", [[error localizedDescription] UTF8String]);
	}

	// call a to stop the session
	verbose("(stopping capture session)\n");
	[session stopRunning];

	// quit
	exit(0);
}

@end






// //////////////////////////////////////////////////////////
//
//                         C                               //
//
/////////////////////////////////////////////////////////////


/**
 * print formatted help and options
 */
void printHelp(NSString * commandName) {

  printf("VideoSnap (%s)\n\n", [VERSION UTF8String]);
  
  printf("  Record video and audio from a capture device\n\n");
  
  printf("  You can specify which device to capture from, the duration,\n");
  printf("  encoding, a delay period (before capturing starts) and \n");
  printf("  optionally turn off audio capturing.  The only required\n");
  printf("  argument is a file path. By default videosnap will capture %.1f\n", [DEFAULT_RECORDING_DURATION floatValue]);
  printf("  seconds of video and audio from the default capture device\n");
  printf("  at 30fps, with a medium quality preset to 'movie.mov'\n");
  
  printf("\n    usage: %s [options] [file ...]", [commandName UTF8String]);
  printf("\n  example: %s -t 5.75 -d 'Built-in iSight' -s 'High' my_movie.mov\n\n", [commandName UTF8String]);

  printf("  -l          List attached capture devices\n");
  printf("  -t x.xx     Set duration of video (in seconds, default %.1fs)\n", [DEFAULT_RECORDING_DURATION floatValue]);
  printf("  -w x.xx     Set delay before capturing starts (in seconds, default %.1fs) \n", [DEFAULT_RECORDING_DELAY floatValue]);
  printf("  -d device   Set the capture device by name\n");
  printf("  --no-audio  Don't capture audio\n");
  printf("  -v          Turn ON verbose mode (OFF by default)\n");
  printf("  -h          Show help\n");
  printf("  -s          Set video encoding preset (Medium by default)\n");
  for (id videoPreset in DEFAULT_VIDEO_PRESETS) {
    printf("                %s%s\n", [videoPreset UTF8String], [[videoPreset isEqualToString:DEFAULT_VIDEO_PRESET] ? @" (default)" : @"" UTF8String]);
  }
  printf("\n");
}


/**
 * print a list of available video devices
 */
unsigned long listDevices() {

  NSArray *devices = [VideoSnap videoDevices];
  unsigned long deviceCount = [devices count];

  if (deviceCount > 0) {
    console("Found %li available video devices:\n", deviceCount);
    for (AVCaptureDevice *device in devices) {
      printf("* %s\n", [[device localizedName] UTF8String]);
    }
  } else {
    console("no video devices found.\n");
  }

  return deviceCount;
}


/**
 * process command line arguments and start capturing
 */
int processArgs(int argc, const char * argv[]) {

  // argument defaults
  AVCaptureDevice *device;
  NSString        *filePath;
  NSString        *videoPreset       = DEFAULT_VIDEO_PRESET;
  NSNumber        *delaySeconds      = DEFAULT_RECORDING_DELAY;
  NSNumber        *recordingDuration = DEFAULT_RECORDING_DURATION;
  BOOL            noAudio            = NO;

  int i;
  for (i = 1; i < argc; ++i) {

    // check for switches
    if (argv[i][0] == '-') {

      // noAudio
      if (strcmp(argv[i], "--no-audio") == 0) {
        noAudio = YES;
      }

      // check flag
      switch (argv[i][1]) {

        // show help
        case 'h':
          printHelp([NSString stringWithUTF8String:argv[0]]);
          return 0;
          break;

        // set verbose flag
        case 'v':
          is_verbose = YES;
          break;

        // list devices
        case 'l':
          listDevices();
          return 0;
          break;

        // device
        case 'd':
          if (i+1 < argc) {
            device = [VideoSnap deviceNamed:[NSString stringWithUTF8String:argv[i+1]]];
            if (device == nil) {
              error("Device \"%s\" not found - aborting\n", argv[i+1]);
              return 128;
            }
            ++i;
          }
          break;


        // videoPreset
        case 's':
          if (i+1 < argc) {
            videoPreset = [NSString stringWithUTF8String:argv[i+1]];
            ++i;
          }
          break;

        // delaySeconds
        case 'w':
          if (i+1 < argc) {
            delaySeconds = [NSNumber numberWithFloat:[[NSString stringWithUTF8String:argv[i+1]] floatValue]];
            ++i;
          }
          break;

        // recordingDuration
        case 't':
          if (i+1 < argc) {
            recordingDuration = [NSNumber numberWithFloat:[[NSString stringWithUTF8String:argv[i+1]] floatValue]];
            ++i;
          }
          break;
      }
    } else {
      filePath = [NSString stringWithUTF8String:argv[i]];
    }
  }

  // check we have a file
  if (filePath == nil) {
    filePath = DEFAULT_RECORDING_FILENAME;
    verbose("(no filename specified, using default)\n");
  }

  // check we have a device
  if (device == nil) {
    device = [VideoSnap defaultDevice];
    if (device == nil) {
      error("No video devices found! - aborting\n");
      return 1;
    } else {
      verbose("(no device specified, using default)\n");
    }
  }

  // check we have a duration
  if ([recordingDuration floatValue] <= 0.0f) {
    error("No duration specified! - aborting\n");
    return 128;
  }

  // check we have a valid videoPreset
  NSArray *validChosenSize = [DEFAULT_VIDEO_PRESETS filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *option, NSDictionary *bindings) {
    return [videoPreset isEqualToString:option];
  }]];

  if (!validChosenSize.count) {
    error("Invalid video preset! (must be one of %s) - aborting\n", [[DEFAULT_VIDEO_PRESETS componentsJoinedByString:@", "] UTF8String]);
    return 128;
  }

  // show options in verbose mode
  verbose("(options before recording)\n");
  verbose("  delay:    %.2fs\n",    [delaySeconds floatValue]);
  verbose("  duration: %.2fs\n",    [recordingDuration floatValue]);
  verbose("  file:     %s\n",       [filePath UTF8String]);
  verbose("  video:    %s H.264\n", [videoPreset UTF8String]);
  verbose("  audio:    %s\n",       [noAudio ? @"(none)": @"HQ AAC" UTF8String]);
	verbose("  device:   %s\n",       [[device localizedName] UTF8String]);
	verbose("            %s - %s\n",  [[device modelID] UTF8String], [[device manufacturer] UTF8String]);


  // start capturing video, start a run loop
  if ([VideoSnap captureVideo:device
                     filePath:filePath
            recordingDuration:recordingDuration
                    videoPreset:videoPreset
                    withDelay:delaySeconds
                      noAudio:noAudio]) {
    [[NSRunLoop currentRunLoop] run];
  } else {
    error("Could not initiate a VideoSnap capture\n");
  }

  return 0;
}


/**
 * main entry point
 */
int main(int argc, const char * argv[]) {
  return processArgs(argc, argv);
}
