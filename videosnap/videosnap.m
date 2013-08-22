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
  
  captureSession          = nil;
  captureMovieFileOutput  = nil;
  captureVideoDeviceInput = nil;
  captureAudioDeviceInput = nil;
  recordingStartedDate    = nil;
  maxRecordingSeconds     = 0;
  
  return self;
}


/**
 * return an array of attached QTCaptureDevice's
 */
+ (NSArray *)videoDevices {
  NSMutableArray *results = [NSMutableArray arrayWithCapacity:3];
  [results addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo]];
  [results addObjectsFromArray:[QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed]];
  return results;
}


/**
 * returns the default QTCaptureDevice or nil
 */
+ (QTCaptureDevice *)defaultDevice {
  QTCaptureDevice *device = nil;

  device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
  if (device == nil) {
    device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
  }
  
  return device;
}


/**
 * returns a QTCaptureDevice matching the name or nil
 */
+ (QTCaptureDevice *)deviceNamed:(NSString *)name {
  QTCaptureDevice *deviceFound = nil;

  NSArray *devices = [VideoSnap videoDevices];
  for (QTCaptureDevice *device in devices) {
    if ([name isEqualToString:[device description]]) {
      deviceFound = device;
    }
  }

  return deviceFound;
}


/**
 * start capturing video (after withDelay) writing toFile for withDuration
 */
+ (BOOL)captureVideo:(QTCaptureDevice *)device
                   filePath:(NSString *)filePath
          recordingDuration:(NSNumber *)recordingDuration
                  videoSize:(NSString *)videoSize
                  withDelay:(NSNumber *)delaySeconds
                          noAudio:(BOOL)noAudio {

  if ([delaySeconds floatValue] <= 0.0f) {
    verbose("(no delay)\n");
  } else {
    verbose("(delay %.2lf seconds)\n", [delaySeconds doubleValue]);
    [NSThread sleepForTimeInterval:[delaySeconds floatValue]];
    verbose("(delay period ended)\n");
  }

  // create an instance of VideoSnap and start the capture session
  VideoSnap *videoSnap;
  videoSnap = [[VideoSnap alloc] init];
  
  return [videoSnap startSession:device filePath:filePath recordingDuration:recordingDuration videoSize:videoSize noAudio:noAudio];
}


/**
 * start a capture session on a device, saving to filePath for recordSeconds
 */
- (BOOL)startSession:(QTCaptureDevice *)videoDevice
                   filePath:(NSString *)filePath
          recordingDuration:(NSNumber *)recordingDuration
                  videoSize:(NSString *)videoSize
                          noAudio:(BOOL)noAudio {

  BOOL success = NO;
  NSError *error;
  
  captureSession      = [[QTCaptureSession alloc] init];
  maxRecordingSeconds = recordingDuration;

  if (videoDevice) {
    // attempt to open the device for capturing
    success = [videoDevice open:&error];
    if (!success) {
      error( "Could not open the video device\n");
      return success;
    }
    
    // add the video device to the capture session as a device input
    verbose("(adding video device to capture session)\n");
    captureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
    success = [captureSession addInput:captureVideoDeviceInput error:&error];
    if (!success) {
      error( "Could not add the video device to the session\n");
      return success;
    }
    
    // add audio device unless noAudio
    if(!noAudio) {
      [self addAudioDevice:videoDevice];
    }
    
    // create the movie file output and add to the session
    captureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
    success = [captureSession addOutput:captureMovieFileOutput error:&error];
    if (!success) {
      error( "Could not add file '%s' as output to the capture session\n", [filePath UTF8String]);
      return success;
    } else {
      [captureMovieFileOutput setDelegate:self];
      [captureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:filePath]];
    }

    // set compression options
    NSString *videoCompression = [NSString stringWithFormat:@"QTCompressionOptions%@SizeH264Video", videoSize];
    [self setCompressionOptions:videoCompression audioCompression:@"QTCompressionOptionsHighQualityAACAudio"];
    
    // start capture session running
    verbose("(starting capture session)\n");
    [captureSession startRunning];
    success = [captureSession isRunning];
  }
  
  return success;
}


/**
 * add audio device to a capture session
 */
- (BOOL)addAudioDevice:(QTCaptureDevice *)videoDevice {
  
  BOOL success = NO;
  NSError *error;
  
  verbose("(adding audio device to capture session)\n");
  // if the video device doesn't supply audio, add an audio device input to the session
  if (![videoDevice hasMediaType:QTMediaTypeSound] && ![videoDevice hasMediaType:QTMediaTypeMuxed]) {
    QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
    success = [audioDevice open:&error];
    
    if (!success) {
      audioDevice = nil;
      error( "Could not open the audio device\n");
      return success;
    }
    
    if (audioDevice) {
      captureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
      success = [captureSession addInput:captureAudioDeviceInput error:&error];
      if (!success) {
        error( "Could not add the audio device to the session\n");
        return success;
      }
    }
  }
  return YES;
}


/**
 * add audio device to a capture session
 */
- (void)setCompressionOptions:(NSString *)videoCompression
             audioCompression:(NSString *)audioCompression {
  
  NSEnumerator *connectionEnumerator = [[captureMovieFileOutput connections] objectEnumerator];
  QTCaptureConnection *connection;
  
  // iterate over each output connection for the capture session and specify the desired compression
  while ((connection = [connectionEnumerator nextObject])) {
    NSString *mediaType = [connection mediaType];
    QTCompressionOptions *compressionOptions = nil;
    // (note: a list of other valid compression types can be found in the QTCompressionOptions.h interface file)
    if ([mediaType isEqualToString:QTMediaTypeVideo]) {
      verbose("(setting video compression to %s)\n", [videoCompression UTF8String]);
      compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:videoCompression];
    } else if ([mediaType isEqualToString:QTMediaTypeSound]) {
      verbose("(setting audio compression to %s)\n", [audioCompression UTF8String]);
      compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:audioCompression];
    }
    
    // set the compression options for the movie file output
    [captureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
  }
}


/**
 * delegate called when camera samples the output buffer
 */
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput
     didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer
       fromConnection:(QTCaptureConnection *)connection {
  
  // check we have started to record some bytes
  // allows us to wait for camera to warm up
  long recordedBytes = [captureMovieFileOutput recordedFileSize];

  if (recordingStartedDate != nil) {
    // check if we have recorded enough video yet, if so stop
    if ([[NSDate date] timeIntervalSinceDate:recordingStartedDate] >= [maxRecordingSeconds floatValue]) {
      [captureMovieFileOutput recordToOutputFileURL:nil];
    }
  } else if(recordedBytes > 0) {
    // set the start date when recording bytes was initiated
    recordingStartedDate = [NSDate date];
  }
}


/**
 * delegate called when output file has been written to
 */
- (void)captureOutput:(QTCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                   forConnections:(NSArray *)connections
                       dueToError:(NSError *)error {
  
  if (error == nil) {
    NSString *outputDuration = QTStringFromTime([captureMovieFileOutput recordedDuration]);
    verbose("(finished writing to movie file duration was %s !)\n", [outputDuration UTF8String]);
    console("Captured %.2f seconds of video to '%s'\n", [maxRecordingSeconds floatValue], [[outputFileURL lastPathComponent] UTF8String]);
  } else {
    error( "Could not finalize writing video to file\n");
    fprintf(stderr, "%s\n", [[error localizedDescription] UTF8String]);
  }

  // call a to stop the session
  verbose("(stopping session)\n");
  [captureSession stopRunning];
  
  if ([[captureVideoDeviceInput device] isOpen])
    [[captureVideoDeviceInput device] close];

  if ([[captureAudioDeviceInput device] isOpen])
    [[captureAudioDeviceInput device] close];
  
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
  printf("Captures a video from a device and saves it to a file.\n");
  printf("If no device is specified, the default device will be used.\n");
  printf("If no filename is specfied, %s will be used.\n", "movie.mov");
  printf("Video/Audio encoded with QuickTime H.264/AAC\n");

  printf("\n  usage: %s [options] [filename]", [commandName UTF8String]);
  printf("\n  e.g. %s -t 5.75 -d 'Built-in iSight' -s 'HD720' my_movie.mov\n\n", [commandName UTF8String]);

  printf("  -l          List available video devices\n");
  printf("  -t x.xx     Duration of video x.xx seconds (default %.2f)\n", 6.0);
  printf("  -w x.xx     Wait x.xx seconds before recording (default %.2f)\n", 0.0);
  printf("  -d device   Use a named video device\n");
  printf("  --no-audio  Don't capture audio (video only)\n");
  printf("  -h          Help message\n");
  printf("  -v          Verbose mode\n");
  printf("  -s          Video Size/Quality H.264 options\n");
  printf("                120\n");
  printf("                240\n");
  printf("                SD480 (default)\n");
  printf("                HD720\n\n");
}


/**
 * print a list of available video devices
 */
unsigned long listDevices() {
  
  NSArray *devices = [VideoSnap videoDevices];
  unsigned long deviceCount = [devices count];

  if (deviceCount > 0) {
    console("Found %li available video devices:\n", deviceCount);
    for(QTCaptureDevice *device in devices){
      printf("* %s\n", [[device description] UTF8String]);
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
  QTCaptureDevice *device            = nil;
  NSString        *filePath          = nil;
  NSString        *videoSize         = @"SD480";
  NSNumber        *delaySeconds      = [NSNumber numberWithFloat:0.00];
  NSNumber        *recordingDuration = [NSNumber numberWithFloat:6.00];
  BOOL            noAudio            = NO;
  
  int i;
  for (i = 1; i < argc; ++i) {

    // check for switches
    if (argv[i][0] == '-') {

      // noAudio
      if (strcmp(argv[i], "--no-audio") == 0) {
        noAudio = YES;
        break;
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
            if(device == nil) {
              error("Device \"%s\" not found - aborting\n", argv[i+1]);
              return 1;
            }
            ++i;
          }
          break;
          
          
        // videoSize
        case 's':
          if (i+1 < argc) {
            videoSize = [NSString stringWithUTF8String:argv[i+1]];
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
    filePath = @"movie.mov";
    verbose("(no filename specified, using default => %s)\n", [filePath UTF8String]);
  }

  // check we have a device
  if (device == nil) {
    device = [VideoSnap defaultDevice];
    if( device == nil ){
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
  
  // check we have a valid videoSize
  if (!([videoSize isEqualToString:@"120"] ||
        [videoSize isEqualToString:@"240"] ||
        [videoSize isEqualToString:@"SD480"] ||
        [videoSize isEqualToString:@"HD720"])) {
    error("Invalid video size specified! (can be 120, 240, SD480 or HD720) - aborting\n");
    return 128;
  }

  // show options in verbose mode
  verbose("(options before recording)\n");
  verbose("  delay:    %.2fs\n",    [delaySeconds floatValue]);
  verbose("  duration: %.2fs\n",    [recordingDuration floatValue]);
  verbose("  file:     %s\n",       [filePath UTF8String]);
  verbose("  device:   %s\n",       [[device description] UTF8String]);
  verbose("  video:    %s H.264\n", [videoSize UTF8String]);
  verbose("  audio:    %s\n",       [noAudio ? @"no": @"yes" UTF8String]);

  // start capturing video, start a run loop
  if ([VideoSnap captureVideo:device filePath:filePath recordingDuration:recordingDuration videoSize:videoSize withDelay:delaySeconds noAudio:noAudio]) {
    [[NSRunLoop currentRunLoop] run];
  } else {
    error("Could not initiate a VideoSnap capture\n");
  }
  
  return 0;
}


/**
 * main
 */
int main(int argc, const char * argv[]) {
  return processArgs(argc, argv);
}
