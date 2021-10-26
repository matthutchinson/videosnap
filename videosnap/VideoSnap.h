//
//  VideoSnap.h
//  VideoSnap
//
//  Created by Matthew Hutchinson
//

#import <CoreMedia/CoreMedia.h>
#import <CoreMediaIO/CMIOHardware.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

// logging
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) fprintf(stdout, __VA_ARGS__)
#define verbose(...) (self->isVerbose && fprintf(stdout, __VA_ARGS__))
#define verbose_error(...) (self->isVerbose && fprintf(stderr, __VA_ARGS__))

// VideoSnap
@interface VideoSnap : NSObject <AVCaptureFileOutputRecordingDelegate> {
    AVCaptureSession *session;
    AVCaptureConnection *conn;
    AVCaptureMovieFileOutput *movieFileOutput;
    NSMutableArray *connectedDevices;
    BOOL isVerbose;
    NSString *filePath;
}

//
// Class methods
//

/**
 * Prints help text to stdout
 */
+(void)printHelp;

//
// Instance methods
//

/**
 * Initializer, setting verbosity
 */
-(id)initWithVerbosity:(BOOL)verbosity;

/**
 * Process command line args and return program ret code
 */
-(int)processArgs:(NSArray *)arguments;

/**
 * Discover all video/muxed capture devices
 */
-(void)discoverDevices;

/**
 * Enable connected devices for ScreenCapture through CoreMedia DAL (Device Abstraction Layer)
 */
- (void)enableScreenCaptureWithDAL;

/**
 * List all connected devices by name to stdout
 */
-(void)listConnectedDevices;

/**
  * Get default generated filename
  */
 -(NSString *)defaultGeneratedFilename;

/**
 * Returns the default device (first found)  or nil if none found
 *
 * @return AVCaptureDevice
 */
-(AVCaptureDevice *)defaultDevice;

/**
 * Returns a device matching on localizedName or nil if not found
 *
 * @return AVCaptureDevice
 */
-(AVCaptureDevice *)deviceNamed:(NSString *)name;

/**
 * Starts a capture session on a device for recordSeconds saving to filePath 
 * using the encodingPreset (with an optional delay) returns (BOOL) YES if 
 * successful
 *
 * @return BOOL
 */
-(BOOL)startSession:(AVCaptureDevice *)device recordingDuration:(NSNumber *)recordSeconds encodingPreset:(NSString *)encodingPreset delaySeconds:(NSNumber *)delaySeconds noAudio:(BOOL)noAudio;

/**
  * Delegates togglePauseRecording to movieFileOutput, with SIGINT value from handler
  */
 -(void)togglePauseRecording:(int)sigNum;

/**
 * Adds an audio device to the capture session, uses the audio from chosen video device
 * If the video device doesn't supply audio, add a default audio device (if one is available)
 *
 * @return BOOL
 */
-(BOOL)addAudioDevice:(AVCaptureDevice *)videoDevice;

/**
 * Delegates isRecording to movieFileOutput, returns true or false
 *
 * @return BOOL
 */
-(BOOL)isRecording;

/**
 * Delegates stopRecording to movieFileOutput, with SIGINT value from handler
 */
-(void)stopRecording:(int)sigNum;

/**
 * AVCaptureMovieFileOutput delegate, called when output file has been finally
 * written to, due to error or stopping the capture session
 */
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error;

@end
