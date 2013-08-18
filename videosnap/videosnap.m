//
//  VideoSnap.m
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2013 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"

@implementation VideoSnap

- (id)init {
    
	self = [super init];
    mCaptureSession = nil;
    mCaptureMovieFileOutput = nil;
    mCaptureVideoDeviceInput = nil;
	mCaptureAudioDeviceInput = nil;
	return self;
}


// return an array of attached video devices 
+ (NSArray *)videoDevices {
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:3];
    [results addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]];
    [results addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]];
    return results;
}


// returns the default video device or nil
+ (QTCaptureDevice *)defaultDevice {
	QTCaptureDevice *device = nil;
    
	device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
	if( device == nil ){
        device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
	}
    return device;
}

// returns the named capture device or nil
+ (QTCaptureDevice *)deviceNamed:(NSString *)name {
    QTCaptureDevice *result = nil;
    
    NSArray *devices = [VideoSnap videoDevices];
	for( QTCaptureDevice *device in devices ){
        if ( [name isEqualToString:[device description]] ){
            result = device;
        }
    }
    
    return result;
}

// capture video and save to a file
+ (BOOL)captureVideo:(QTCaptureDevice *)device
             toFile:(NSString *)path
       withDuration:(NSNumber *)recordSeconds
          withDelay:(NSNumber *)delaySeconds {
              
    if( [delaySeconds floatValue] <= 0.0f ){
        verbose("(no delay)\n");
    } else {
        verbose("(delay %.2lf seconds)\n", [delaySeconds doubleValue]);
        NSDate *now = [[NSDate alloc] init];
        [[NSRunLoop currentRunLoop] runUntilDate:[now dateByAddingTimeInterval: [delaySeconds doubleValue]]];
        [now release];
        verbose("(delay period ended)\n");
    }
              
              
    // instance of VideoSnap
    VideoSnap *videoSnap;
    videoSnap = [[VideoSnap alloc] init];
    verbose("(starting device...)\n");
    [videoSnap startSession:device toFile:path withDuration:recordSeconds ];
    [videoSnap release];
       
    return YES;
}


- (void)startSession:(QTCaptureDevice *)device
              toFile:(NSString *)path
        withDuration:(NSNumber *)recordSeconds {
              
    // FROM MY RECORDER //

    // Create the capture session

    mCaptureSession = [[QTCaptureSession alloc] init];

    // Connect inputs and outputs to the session

    BOOL success = NO;
    NSError *error;
              
    success = [device open:&error];
  
    if (!success) {
      device = nil;
      // Handle error
    }


    if (device) {
        //Add the video device to the session as a device input
        
        mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
        success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
        if (!success) {
            // Handle error
        }
        
        // If the video device doesn't also supply audio, add an audio device input to the session
        
        if (![device hasMediaType:QTMediaTypeSound] && ![device hasMediaType:QTMediaTypeMuxed]) {
            
            QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
            success = [audioDevice open:&error];
            
            if (!success) {
                audioDevice = nil;
                // Handle error
            }
            
            if (audioDevice) {
                mCaptureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
                
                success = [mCaptureSession addInput:mCaptureAudioDeviceInput error:&error];
                if (!success) {
                    // Handle error
                }
            }
        }
        
        // Create the movie file output and add it to the session
        
        mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
        success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
        if (!success) {
            // Handle error
        }
        
        [mCaptureMovieFileOutput setDelegate:self];
        
        
        // Set the compression for the audio/video that is recorded to the hard disk.
        
        NSEnumerator *connectionEnumerator = [[mCaptureMovieFileOutput connections] objectEnumerator];
        QTCaptureConnection *connection;
        
        // iterate over each output connection for the capture session and specify the desired compression
        while ((connection = [connectionEnumerator nextObject])) {
            NSString *mediaType = [connection mediaType];
            QTCompressionOptions *compressionOptions = nil;
            // specify the video compression options
            // (note: a list of other valid compression types can be found in the QTCompressionOptions.h interface file)
            if ([mediaType isEqualToString:QTMediaTypeVideo]) {
                // use H.264
                compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptions240SizeH264Video"];
                // specify the audio compression options
            } else if ([mediaType isEqualToString:QTMediaTypeSound]) {
                // use AAC Audio
                compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
            }
            
            // set the compression options for the movie file output
            [mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
        }
        
        // Associate the capture view in the UI with the session
        // [mCaptureView setCaptureSession:mCaptureSession];
        
        [mCaptureSession startRunning];
        
    }

    [mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:path]];

    verbose("(recording for %.2lf seconds)\n", [recordSeconds doubleValue]);
    NSDate *now = [[NSDate alloc] init];
    [[NSRunLoop currentRunLoop] runUntilDate:[now dateByAddingTimeInterval: [recordSeconds doubleValue]]];
    [now release];
    verbose("(recording period ended)\n");

    [mCaptureMovieFileOutput recordToOutputFileURL:nil];
    [mCaptureSession stopRunning];

    if ([[mCaptureVideoDeviceInput device] isOpen])
        [[mCaptureVideoDeviceInput device] close];

    if ([[mCaptureAudioDeviceInput device] isOpen])
        [[mCaptureAudioDeviceInput device] close];
              
}


// deallocate
- (void)dealloc {
	
	if( mCaptureSession )			[mCaptureSession release];
	if( mCaptureVideoDeviceInput )  [mCaptureVideoDeviceInput release];
	if( mCaptureAudioDeviceInput )  [mCaptureAudioDeviceInput release];
    if( mCaptureMovieFileOutput )   [mCaptureMovieFileOutput release];
    [super dealloc];
}

@end







// //////////////////////////////////////////////////////////
//
//                         C                               //
//
/////////////////////////////////////////////////////////////


/**
 * Print formatted help and options information.
 */
void printHelp(NSString * commandName) {
    printf( "VideoSnap (version: %s)\n\n", [VERSION UTF8String] );
    printf( "Captures a video from a device and saves it to a file.\n" );
    printf( "If no device is specified, the default device will be used.\n" );
    printf( "If no filename is specfied, %s will be used.\n", "movie.mov");
    printf( "Video/Audio is encoded with H264/AAC.\n" );
    
    printf( "\n  usage: %s [options] [filename]", [commandName UTF8String] );
    printf( "\n  e.g. %s -t 5.75 -d 'Built-in iSight' my_movie.mov\n\n", [commandName UTF8String]  );
    
    printf( "  -t x.xx     Duration of video x.xx seconds (default %.2f)\n", 6.00);
    printf( "  -w x.xx     Wait x.xx seconds before recording (default %.2f)\n", 0.00);
    printf( "  -l          List available video devices\n" );
    printf( "  -d device   Use a named video device\n" );
    printf( "  -h/?        Help message\n" );
    printf( "  -v          Verbose mode\n");
}


/**
 * Print the list of devices from VideoSnap videoDevices.
 */
unsigned long listDevices() {
    NSArray *devices = [VideoSnap videoDevices];
    unsigned long deviceCount = [devices count];
    
    deviceCount > 0
    ? printf("Found %li video devices:\n", deviceCount)
    : printf("No video devices found.\n");
    
	for( QTCaptureDevice *device in devices ){
		printf( "%s\n", [[device description] UTF8String] );
	}
    return deviceCount;
}


/**
 * Process command line arguments and execute program.
 */
int processArgs(int argc, const char * argv[]) {
    
    QTCaptureDevice *device        = nil;
	NSString        *filename      = nil;
	NSNumber        *delaySeconds  = [NSNumber numberWithFloat:0.00];
    NSNumber        *recordSeconds = [NSNumber numberWithFloat:6.00];
	
	int i;
	for( i = 1; i < argc; ++i ) {
        
		// command line switches
		if (argv[i][0] == '-') {
                
            // check switch flag
            switch (argv[i][1]) {
                    
                // show help
                case '?':
                case 'h':
                    printHelp( [NSString stringWithUTF8String:argv[0]] );
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
                    if( i+1 < argc ){
                        device = [VideoSnap deviceNamed:[NSString stringWithUTF8String:argv[i+1]]];
                        if( device == nil ){
                            error( "Device \"%s\" not found.\n", argv[i+1] );
                            return 11;
                        }
                        ++i;
                    }
                    break;
                    
                // delaySeconds
                case 'w':
                    if( i+1 < argc ){
                        delaySeconds = [NSNumber numberWithFloat:[[NSString stringWithUTF8String:argv[i+1]] floatValue]];
                        ++i;
                    }
                    break;
                    
                // recordSeconds
                case 't':
                    if( i+1 < argc ){
                        recordSeconds = [NSNumber numberWithFloat:[[NSString stringWithUTF8String:argv[i+1]] floatValue]];
                        ++i;
                    }
                    break;
            }
		} else {
            // set filename
			filename = [NSString stringWithUTF8String:argv[i]];
		}
	}
    
    // check we have a filename
    if( filename == nil ){
        verbose( "(no filename specified, using default)\n" );
        filename = @"movie.mov";
    }
    
    // check we have a device
	if( device == nil ){
		device = [VideoSnap defaultDevice];
        if( device == nil ){
            error( "No video devices found! Aborting\n" );
            return 2;
        } else {
            verbose( "(no device specified, using default)\n" );
        }
	}
    
    // check we have a recordSeconds
    if( [recordSeconds floatValue] <= 0.0f ) {
        error( "No duration specified! Aborting\n" );
        return 3;
    }
    
    // show options in verbose mode
    verbose("(options before recording)\n");
    verbose("  delay:    %.2fs\n", [delaySeconds floatValue]);
    verbose("  record:   %.2fs\n", [recordSeconds floatValue]);
    verbose("  filename: %s\n", [filename UTF8String]);
    verbose("  device:   %s\n", [[device description] UTF8String]);
    
    // record
    if( [VideoSnap captureVideo:device toFile:filename withDuration:recordSeconds withDelay:delaySeconds] ){
        console( "DONE! %s\n", [filename UTF8String] );
    } else {
        error( "Error.\n" );
    }
    
    return 0;
}


/**
 * Main entry point
 */
int main(int argc, const char * argv[]) {
    
    // set up appropriate pools and loops
    // http://lists.apple.com/archives/cocoa-dev/2003/Apr/msg01638.html
	NSAutoreleasePool *pool;
	pool = [[NSAutoreleasePool alloc] init];
	
    // process command line args
    int result = processArgs(argc, argv);
    
    // drain the pool
    [pool drain];

    return result;
}