//
//  VideoSnap.h
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2016 Matthew Hutchinson. All rights reserved.
//


//#import <Foundation/Foundation.h>
//#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

// logging helpers
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) printf(__VA_ARGS__)
#define verbose(...) (is_verbose && fprintf(stderr, __VA_ARGS__))

// version
#define VERSION @"0.0.2"

// defaults
#define DEFAULT_RECORDING_DELAY    @0.5
#define DEFAULT_RECORDING_DURATION @6.0
#define DEFAULT_RECORDING_FILENAME @"movie.mov"
#define DEFAULT_RECORDING_SIZE     @"SD480"
#define DEFAULT_VIDEO_SIZES        @[@"120", @"240", @"SD480", @"HD720"]

// default verbose flag
BOOL is_verbose = YES;

// VideoSnap
@interface VideoSnap : NSObject {

//  QTCaptureSession         *captureSession;          // session
//  QTCaptureMovieFileOutput *captureMovieFileOutput;  // file output
//  QTCaptureDeviceInput     *captureVideoDeviceInput; // video input
//  QTCaptureDeviceInput     *captureAudioDeviceInput; // audio input
  NSDate                   *recordingStartedDate;    // record timing
  NSNumber                 *maxRecordingSeconds;     // record duration
}

// class methods

/**
 * Returns attached AVCaptureDevice objects that have video. Includes
 * video-only devices (AVMediaTypeVideo) and any audio/video devices
 *
 * @return array of video devices
 */
+(NSArray *)videoDevices;

/**
 * Returns default AVCaptureDevice object for video or nil if none found
 *
 * @return AVCaptureDevice
 */
+(AVCaptureDevice *)defaultDevice;

/**
 * Returns AVCaptureDevice matching name or nil if a device matching the name
 * cannot be found
 *
 * @return AVCaptureDevice
 */
+(AVCaptureDevice *)deviceNamed:(NSString *)name;

/**
 * Captures video from a device and saves it to a file, returns (BOOL) YES if
 * successful
 *
 * @return BOOL
 */
//+(BOOL)captureVideo:(QTCaptureDevice *)videoDevice filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds videoSize:(NSString *)videoSize withDelay:(NSNumber *)delaySeconds noAudio:(BOOL)noAudio;


// instance methods

-(id)init;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns (BOOL) YES if successful
 *
 * @return BOOL
 */
//-(BOOL)addAudioDevice:(QTCaptureDevice *)videoDevice;

/**
 * Sets compression video/audio options on the output file
 */
//-(void)setCompressionOptions:(NSString *)videoCompression audioCompression:(NSString *)audioCompression;

/**
 * Starts a capture session on device, saving to a filePath for recordSeconds
 * return (BOOL) YES successful or (BOOL) NO if not
 *
 * @return BOOL
 */
//-(BOOL)startSession:(QTCaptureDevice *)device filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds videoSize:(NSString *)videoSize withDelay:(NSNumber *)withDelay noAudio:(BOOL)noAudio;

/**
 * QTCaptureMovieFileOutput delegate called when camera samples from the output
 * buffer
 */
//-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didOutputSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection;

/**
 * QTCaptureMovieFileOutput delegate, called when output file has been finally
 * written to
 */
//-(void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error;

@end
