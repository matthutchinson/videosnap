//
//  VideoSnap.h
//  VideoSnap
//
//  Created by Matthew Hutchinson on 18/08/2013.
//  Copyright (c) 2016 Matthew Hutchinson. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>


#define VERSION @"0.0.2"

// logging
#define error(...) fprintf(stderr, __VA_ARGS__)
#define console(...) printf(__VA_ARGS__)
#define verbose(...) (is_verbose && fprintf(stderr, __VA_ARGS__))
#define verbose_error(...) (is_verbose && fprintf(stderr, __VA_ARGS__))

// defaults
#define CAPTURE_FRAMES_PER_SECOND  @30
#define DEFAULT_RECORDING_DELAY    @0.5
#define DEFAULT_RECORDING_DURATION @6.0
#define DEFAULT_RECORDING_FILENAME @"movie.mov"
#define DEFAULT_VIDEO_PRESET       @"Medium"
#define DEFAULT_VIDEO_PRESETS      @[@"High", @"Medium", @"Low", @"640x480", @"1280x720"]

// video preset options:
// High - Highest recording quality (varies per device)
// Medium - Suitable for WiFi sharing (actual values may change)
// Low - Suitable for 3G sharing (actual values may change)
// 640x480 - 640x480 VGA (check its supported before setting it)
// 1280x720 - 1280x720 720p HD (check its supported before setting it)

// default verbose flag
BOOL is_verbose = NO;


// VideoSnap
@interface VideoSnap : NSObject <AVCaptureFileOutputRecordingDelegate> {
  AVCaptureSession         *session;
  AVCaptureMovieFileOutput *movieFileOutput;
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
+(BOOL)captureVideo:(AVCaptureDevice *)videoDevice filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds videoPreset:(NSString *)videoPreset withDelay:(NSNumber *)delaySeconds noAudio:(BOOL)noAudio;


// instance methods

-(id)init;

/**
 * Starts a capture session on device, saving to a filePath for recordSeconds
 * return (BOOL) YES successful or (BOOL) NO if not
 *
 * @return BOOL
 */
-(BOOL)startSession:(AVCaptureDevice *)device filePath:(NSString *)path recordingDuration:(NSNumber *)recordSeconds videoPreset:(NSString *)videoPreset withDelay:(NSNumber *)withDelay noAudio:(BOOL)noAudio;

/**
 * Adds an audio device to the capture session, uses the audio from videoDevice
 * if it is available, returns (BOOL) YES if successful
 *
 * @return BOOL
 */
-(BOOL)addAudioDevice:(AVCaptureDevice *)videoDevice;

/**
 * AVCaptureMovieFileOutput delegate, called when output file has been finally
 * written to
 */
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error;

@end