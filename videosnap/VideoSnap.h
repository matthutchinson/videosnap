//
//  VideoSnap.h
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2016 Matthew Hutchinson. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

// logging
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) printf(__VA_ARGS__)
#define verbose(...) (YES && fprintf(stderr, __VA_ARGS__))
#define verbose_error(...) (YES && fprintf(stderr, __VA_ARGS__))

// VideoSnap
@interface VideoSnap : NSObject <AVCaptureFileOutputRecordingDelegate> {
  AVCaptureSession         *session;
  AVCaptureMovieFileOutput *movieFileOutput;
}

// class methods


/**
 * Prints help text to stdout
 */
+(void)printHelp;

/**
 * Print connected capture device details to stdout
 */
+(void)listDevices;


/**
 * Process command line args and return ret code
 */
+(int)processArgs:(NSArray *)arguments;

/**
 * Returns attached AVCaptureDevice objects that have video. Includes
 * any devices supporting AVMediaTypeVideo and AVMediaTypeMuxed (audio & video)
 *
 * @return NSArray of video devices
 */
+(NSArray *)videoDevices;

/**
 * Returns the default AVCaptureDevice object for video or nil if none found
 *
 * @return AVCaptureDevice
 */
+(AVCaptureDevice *)defaultDevice;

/**
 * Returns a AVCaptureDevice matching on localizedName or nil if not found
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
+(BOOL)captureVideo:(AVCaptureDevice *)videoDevice filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds encodingPreset:(NSString *)encodingPreset delaySeconds:(NSNumber *)delaySeconds noAudio:(BOOL)noAudio;


// instance methods

-(id)init;

/**
 * Starts a capture session on a device for recordSeconds saving to filePath 
 * using the encodingPreset (with an optional delay) returns (BOOL) YES if 
 * successful
 *
 * @return BOOL
 */
-(BOOL)startSession:(AVCaptureDevice *)device filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds encodingPreset:(NSString *)encodingPreset delaySeconds:(NSNumber *)delaySeconds noAudio:(BOOL)noAudio;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns (BOOL) YES if successful
 *
 * @return BOOL
 */
-(BOOL)addAudioDevice:(AVCaptureDevice *)videoDevice;

/**
 * AVCaptureMovieFileOutput delegate, called when output file has been finally
 * written to, due to error or stopping the capture session 
 */
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error;

@end