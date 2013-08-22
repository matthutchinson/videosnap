//
//  VideoSnap.h
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2013 Matthew Hutchinson. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#include "VideoSnap.h"

// logging helpers
#ifndef videosnap_VideoSnap_h
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) printf(__VA_ARGS__)
#define verbose(...) (is_verbose && fprintf(stderr, __VA_ARGS__))
#endif


// default verbose flag
BOOL is_verbose = NO;

// versioning (bump up for new releases)
NSString *VERSION = @"0.0.1";


// VideoSnap
@interface VideoSnap : NSObject {

  QTCaptureSession            *captureSession;          // session
  QTCaptureMovieFileOutput    *captureMovieFileOutput;  // file output
  QTCaptureDeviceInput        *captureVideoDeviceInput; // video input
  QTCaptureDeviceInput        *captureAudioDeviceInput; // audio input
  NSDate                      *recordingStartedDate;    // record timing
  NSNumber                    *maxRecordingSeconds;     // record duration
}

// Class methods

/**
 * Returns attached QTCaptureDevice objects that have video. Includes 
 * video-only devices (QTMediaTypeVideo) and any audio/video devices
 *
 * @return autoreleased array of video devices
 */
+(NSArray *)videoDevices;

/**
 * Returns default QTCaptureDevice object for video or nil if none found
 *
 * @return QTCaptureDevice
 */
+(QTCaptureDevice *)defaultDevice;

/**
 * Returns QTCaptureDevice matching name or nil if a device matching the name 
 * cannot be found
 *
 * @return QTCaptureDevice
 */
+(QTCaptureDevice *)deviceNamed:(NSString *)name;

/**
 * Captures video from a device and saves it to a file, returns (BOOL) YES if
 * successful
 *
 * @return BOOL
 */
+(BOOL)captureVideo:(QTCaptureDevice *)videoDevice filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds videoSize:videoSize withDelay:(NSNumber *)delaySeconds noAudio:(BOOL)noAudio;



// Instance methods

-(id)init;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns (BOOL) YES if successful
 *
 * @return BOOL
 */
-(BOOL)addAudioDevice:(QTCaptureDevice *)videoDevice;

/**
 * Sets compression options on the output file
 */
-(void)setCompressionOptions:(NSString *)videoCompression audioCompression:(NSString *)audioCompression;

/**
 * Starts a capture session on device, saving to a filePath for recordSeconds
 * return (BOOL) YES successful or (BOOL) NO if not
 *
 * @return BOOL
 */
-(BOOL)startSession:(QTCaptureDevice *)device filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds videoSize:videoSize noAudio:(BOOL)noAudio;

/**
 * QTCaptureMovieFileOutput delegate called when camera samples from the output 
 * buffer
 */
-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;

/**
 * QTCaptureMovieFileOutput delegate, called when output file has been finally
 * written to
 */
-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;

@end