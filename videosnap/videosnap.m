//
//  VideoSnap.m
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2020 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"

@implementation VideoSnap


/**
 * print formatted help and options for the command
 */
+ (void)printHelp {

	printf("VideoSnap (%s)\n\n", [VERSION UTF8String]);

	printf("Record video and audio from a capture device\n\n");

	printf("You can specify which device to capture from, the duration, encoding and a delay\n");
	printf("period (before capturing starts). You can also disable audio recording.\n");
	printf("By default videosnap will capture both video and audio from the default capture\n");
	printf("device at %ifps, with a Medium quality preset and a short (%.1fs) warm-up delay.\n", DEFAULT_FRAMES_PER_SECOND, DEFAULT_RECORDING_DELAY);

	printf("\nIf no duration is specified, videosnap will record until you cancel with [Ctrl+c]\n");
	printf("You can also use videosnap to list attached capture devices by name.\n");

	printf("\n  usage: videosnap [options] [file ...]");
	printf("\nexample: videosnap -t 5.75 -d 'Built-in iSight' -p 'High' my_movie.mov\n\n");

	printf("  -l          List attached capture devices\n");
	printf("  -w x.xx     Set delay before capturing starts (in seconds, default %.1fs) \n", DEFAULT_RECORDING_DELAY);
	printf("  -t x.xx     Set duration of video (in seconds)\n");
	printf("  -d device   Set the capture device (by name, use -l to list attached devices)\n");
	printf("  --no-audio  Don't capture audio\n");
	printf("  -v          Turn ON verbose mode (OFF by default)\n");
	printf("  -h          Show help\n");
	printf("  -p          Set the encoding preset (Medium by default)\n");

	NSArray *encodingPresets = [DEFAULT_ENCODING_PRESETS componentsSeparatedByString:@", "];
	for (id encodingPreset in encodingPresets) {
		printf("                %s%s\n", [encodingPreset UTF8String], [[encodingPreset isEqualToString:DEFAULT_ENCODING_PRESET] ? @" (default)" : @"" UTF8String]);
	}
	printf("\n");
}


/**
 * print connected capture device details to stdout
 */
+ (void)listDevices {

	NSArray *devices = [VideoSnap videoDevices];
	unsigned long deviceCount = [devices count];

	if (deviceCount > 0) {
		console("Found %li available video devices:\n", deviceCount);
		for (AVCaptureDevice *device in devices) {
			printf("* %s\n", [[device localizedName] UTF8String]);
		}
	} else {
		console("No video devices found.\n");
	}
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
 * returns a AVCaptureDevice matching on localizedName or nil if not found
 */
+ (AVCaptureDevice *)deviceNamed:(NSString *)name {
  AVCaptureDevice *device = nil;
  NSArray *devices = [VideoSnap videoDevices];
  for (AVCaptureDevice *thisDevice in devices) {
    if ([name isEqualToString:[thisDevice localizedName]]) {
      device = thisDevice;
    }
  }

  return device;
}


/**
 * initialization
 */
- (id)init {
	return [super init];
}


/**
 * process command line args and return ret code
 * TODO: create a seperate class for this, and build a NSDictionary for VideoSnap
 *       consider using NSUserDefaults somehow
 *       http://perspx.com/archives/parsing-command-line-arguments-nsuserdefaults/
 */
- (int)processArgs:(NSArray *)arguments {

	// argument defaults
	AVCaptureDevice *device;
	NSString        *filePath;
	NSString        *encodingPreset    = DEFAULT_ENCODING_PRESET;
	NSNumber        *delaySeconds      = [NSNumber numberWithFloat:DEFAULT_RECORDING_DELAY];
	NSNumber        *recordingDuration = nil;
	BOOL            noAudio            = NO;

	isVerbose = NO;

	int argc = (int)[arguments count];

	for (int i = 1; i < argc; i++) {
		NSString *argValue;
		NSString *arg = [arguments objectAtIndex: i];

		// set arguement value if present
		if (i+1 < argc) {
			argValue = [arguments objectAtIndex: i+1];
		}

		// check for switches
		if ([arg characterAtIndex:0] == '-') {

			if([arg isEqualToString: @"--no-audio"]) {
				noAudio = YES;
			}
            

			switch ([arg characterAtIndex:1]) {
					// show help
				case 'h':
					[VideoSnap printHelp];
					return 0;
					break;

					// set verbose flag
				case 'v':
					isVerbose = YES;
					break;

					// list devices
				case 'l':
					[VideoSnap listDevices];
					return 0;
					break;

					// device
				case 'd':
					if (i+1 < argc) {
						device = [VideoSnap deviceNamed:argValue];
						if (device == nil) {
							error("Device \"%s\" not found - aborting\n", [argValue UTF8String]);
							return 128;
						}
						++i;
					}
					break;


					// encodingPreset
				case 'p':
					if (i+1 < argc) {
						encodingPreset = argValue;
						++i;
					}
					break;

					// delaySeconds
				case 'w':
					if (i+1 < argc) {
						delaySeconds = [NSNumber numberWithFloat:[argValue floatValue]];
						++i;
					}
					break;

					// recordingDuration
				case 't':
					if (i+1 < argc) {
						recordingDuration = [NSNumber numberWithFloat:[argValue floatValue]];
						++i;
					}
					break;
			}
		} else  {
			filePath = arg;
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

	// check we have a positive non zero duration
	if ([recordingDuration floatValue] <= 0.0f) {
		recordingDuration = nil;
	}

	// check we have a valid encodingPreset
	NSArray *encodingPresets = [DEFAULT_ENCODING_PRESETS componentsSeparatedByString:@", "];
	NSArray *validChosenSize = [encodingPresets filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *option, NSDictionary *bindings) {
		return [encodingPreset isEqualToString:option];
	}]];

	if (!validChosenSize.count) {
		error("Invalid video preset! (must be one of %s) - aborting\n", [DEFAULT_ENCODING_PRESETS UTF8String]);
		return 128;
	}

	// start capturing video, start a run loop

	if ([self startSession:device
								filePath:filePath
			 recordingDuration:recordingDuration
					encodingPreset:encodingPreset
						delaySeconds:delaySeconds
								 noAudio:noAudio]) {

		if(recordingDuration != nil) {
			console("Started capture...\n");
		} else {
			console("Started capture (ctrl+c to stop)...\n");
		}
		[[NSRunLoop currentRunLoop] run];
	} else {
		error("Could not initiate a VideoSnap capture\n");
	}
	
	return 0;
}


/**
 * toggle verbose output in logging
 */
- (void)setVerbosity:(BOOL)verbosity {
	isVerbose = verbosity;
}


/**
 * start a capture session on a device, saving to filePath for recordSeconds
 */
- (BOOL)startSession:(AVCaptureDevice *)videoDevice
            filePath:(NSString *)filePath
   recordingDuration:(NSNumber *)recordingDuration
			encodingPreset:(NSString *)encodingPreset
				delaySeconds:(NSNumber *)delaySeconds
             noAudio:(BOOL)noAudio {

  BOOL success = NO;
  NSError *nserror;

	// show options
	verbose("(options before recording)\n");
	verbose("  delay:    %.2fs\n",    [delaySeconds floatValue]);
	verbose("  duration: %.2fs\n",    [recordingDuration floatValue]);
	verbose("  file:     %s\n",       [filePath UTF8String]);
	verbose("  video:    %s\n",       [encodingPreset UTF8String]);
	verbose("  audio:    %s\n",       [noAudio ? @"(none)": @"HQ AAC" UTF8String]);
	verbose("  device:   %s\n",       [[videoDevice localizedName] UTF8String]);
	verbose("            %s - %s\n",  [[videoDevice modelID] UTF8String], [[videoDevice manufacturer] UTF8String]);

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

		// set capture frame rate (fps)
		int32_t fps = DEFAULT_FRAMES_PER_SECOND;
		verbose("(set capture framerate to %i fps)\n", fps);
		AVCaptureConnection *conn = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
		if([conn isVideoMinFrameDurationSupported]) {
			conn.videoMinFrameDuration = CMTimeMake(1, fps);
		}
		if([conn isVideoMaxFrameDurationSupported]) {
			conn.videoMaxFrameDuration = CMTimeMake(1, fps);
		}

		// set max duration and min free space in bytes before recording can start
		if(recordingDuration != nil) {
		  CMTime maxDuration = CMTimeMakeWithSeconds([recordingDuration floatValue], fps);
		  movieFileOutput.maxRecordedDuration = maxDuration;
	  }
		movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;

		if ([session canAddOutput:movieFileOutput]) {
			[session addOutput:movieFileOutput];
		} else {
			error("Could not add file '%s' as output to the capture session\n", [filePath UTF8String]);
			return success;
		}

		verbose("(setting encoding preset)\n");
		NSString *capturePreset = [NSString stringWithFormat:@"AVCaptureSessionPreset%@", encodingPreset];
		if ([session canSetSessionPreset:capturePreset]) {
			[session setSessionPreset:capturePreset];
	  } else {
			verbose("(could not set encoding preset '%s' for this device, defaulting to Medium)\n", [encodingPreset UTF8String]);
			[session setSessionPreset:AVCaptureSessionPresetMedium];
		}

		// delete the target file if it exists
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if([fileManager fileExistsAtPath:filePath]) {
			verbose("(file at '%s' exists, deleting it)\n", [filePath UTF8String]);
			NSError *fileError = nil;

			if (![fileManager removeItemAtPath:filePath error:&fileError]) {
				error("File '%s' exists, and could not be deleted\n", [filePath UTF8String]);
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
 * check if we are recording or not
 */
- (BOOL)isRecording {
	return [movieFileOutput isRecording];
}


/**
 * stops recording to the file
 */
- (void)stopRecording:(int)sigNum {
	verbose("\n(caught signal: [%d])\n", sigNum);
	if([movieFileOutput isRecording]) {
		verbose("(stopping recording)\n");
		[movieFileOutput stopRecording];
	}
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

	// call a to stop the session
	verbose("(stopping capture session)\n");
	[session stopRunning];

	if(captureSuccessful) {
		NSNumber *outputDuration = [NSNumber numberWithFloat: CMTimeGetSeconds([movieFileOutput recordedDuration])];
		console("\nCaptured %.2f seconds of video to '%s'\n", [outputDuration floatValue], [[outputFileURL lastPathComponent] UTF8String]);
		exit(0);
	} else {
		error("\nFailed to capture any video\n");
		verbose_error("(reason: %s)\n", [[error localizedDescription] UTF8String]);
		exit(1);
	}
}

@end
