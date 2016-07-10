//
//  main.m
//  videosnap
//
//  Created by Matthew Hutchinson on 10/07/2016.
//  Copyright © 2016 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"


// default verbose flag (not a constant)
//BOOL is_verbose = YES;


/**
 * process command line arguments and start capturing
 */
int processArgs(int argc, const char * argv[]) {

	// argument defaults
	AVCaptureDevice *device;
	NSString        *filePath;
	NSString        *encodingPreset    = DEFAULT_ENCODING_PRESET;
	NSNumber        *delaySeconds      = [NSNumber numberWithFloat:DEFAULT_RECORDING_DELAY];
	NSNumber        *recordingDuration = [NSNumber numberWithFloat:DEFAULT_RECORDING_DURATION];
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
					[VideoSnap printHelp];
					return 0;
					break;

					// set verbose flag
				case 'v':
					//  is_verbose = YES;
					break;

					// list devices
				case 'l':
					[VideoSnap listDevices];
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


					// encodingPreset
				case 'p':
					if (i+1 < argc) {
						encodingPreset = [NSString stringWithUTF8String:argv[i+1]];
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

	// check we have a valid encodingPreset
	NSArray *encodingPresets = [DEFAULT_ENCODING_PRESETS componentsSeparatedByString:@", "];
	NSArray *validChosenSize = [encodingPresets filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *option, NSDictionary *bindings) {
																																					 return [encodingPreset isEqualToString:option];
																																					 }]];

	if (!validChosenSize.count) {
		error("Invalid video preset! (must be one of %s) - aborting\n", [DEFAULT_ENCODING_PRESETS UTF8String]);
		return 128;
	}

	// show options in verbose mode
	verbose("(options before recording)\n");
	verbose("  delay:    %.2fs\n",    [delaySeconds floatValue]);
	verbose("  duration: %.2fs\n",    [recordingDuration floatValue]);
	verbose("  file:     %s\n",       [filePath UTF8String]);
	verbose("  video:    %s H.264\n", [encodingPreset UTF8String]);
	verbose("  audio:    %s\n",       [noAudio ? @"(none)": @"HQ AAC" UTF8String]);
	verbose("  device:   %s\n",       [[device localizedName] UTF8String]);
	verbose("            %s - %s\n",  [[device modelID] UTF8String], [[device manufacturer] UTF8String]);


	// start capturing video, start a run loop
	if ([VideoSnap captureVideo:device
										 filePath:filePath
						recordingDuration:recordingDuration
							 encodingPreset:encodingPreset
								 delaySeconds:delaySeconds
											noAudio:noAudio]) {
		[[NSRunLoop currentRunLoop] run];
	} else {
		error("Could not initiate a VideoSnap capture\n");
	}

	return 0;
}



int main(int argc, const char * argv[]) {
	return processArgs(argc, argv);
}