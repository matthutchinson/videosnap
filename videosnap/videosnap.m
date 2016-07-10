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
  return [super init];
}

/**
 * print formatted help and options for the command
 */
+ (void)printHelp {

	printf("VideoSnap (%s)\n\n", [VERSION UTF8String]);

	printf("Record video and audio from a capture device\n\n");

	printf("You can specify which device to capture from, the duration,\n");
	printf("encoding, a delay period (before capturing starts) and optionally\n");
	printf("turn off audio capturing. By default videosnap will capture\n");
	printf("%.1f seconds of video and audio from the default capture device\n", DEFAULT_RECORDING_DURATION);
	printf("at %ifps, with a Medium quality preset and a short warm-up delay\n", DEFAULT_FRAMES_PER_SECOND);
	printf("of %.1fs seconds.\n", DEFAULT_RECORDING_DELAY);

	printf("\nYou can also use videosnap to list attached capture devices by name.\n");

	printf("\n  usage: videosnap [options] [file ...]");
	printf("\nexample: videosnap -t 5.75 -d 'Built-in iSight' -p 'High' my_movie.mov\n\n");

	printf("  -l          List attached capture devices\n");
	printf("  -t x.xx     Set duration of video (in seconds, default %.1fs)\n", DEFAULT_RECORDING_DURATION);
	printf("  -w x.xx     Set delay before capturing starts (in seconds, default %.1fs) \n", DEFAULT_RECORDING_DELAY);
	printf("  -d device   Set the capture device by name\n");
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
 * start capturing video (after delaySeconds) writing toFile for withDuration
 */
+ (BOOL)captureVideo:(AVCaptureDevice *)device
            filePath:(NSString *)filePath
   recordingDuration:(NSNumber *)recordingDuration
			encodingPreset:(NSString *)encodingPreset
				delaySeconds:(NSNumber *)delaySeconds
             noAudio:(BOOL)noAudio {

  // create an instance of VideoSnap and start the capture session
  VideoSnap *videoSnap;
  videoSnap = [[VideoSnap alloc] init];

  return [videoSnap startSession:device
                        filePath:filePath
               recordingDuration:recordingDuration
								  encodingPreset:encodingPreset
										delaySeconds:delaySeconds
                         noAudio:noAudio];
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
		CMTime maxDuration = CMTimeMakeWithSeconds([recordingDuration floatValue], fps);
		movieFileOutput.maxRecordedDuration = maxDuration;
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
		verbose_error("%s\n", [[error localizedDescription] UTF8String]);
	}

	// call a to stop the session
	verbose("(stopping capture session)\n");
	[session stopRunning];

	// quit
	exit(0);
}

@end