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

// logging

#ifndef videosnap_VideoSnap_h
  #define error(...) fprintf(stderr, __VA_ARGS__)
  #define console(...) printf(__VA_ARGS__)
  #define verbose(...) (is_verbose && fprintf(stderr, __VA_ARGS__))
#endif


// default verbose setting

BOOL is_verbose = YES;//NO;

// versioning (bump this for new releases)

NSString *VERSION = @"0.0.1";


// VideoSnap

@interface VideoSnap : NSObject {
    
    QTCaptureSession            *mCaptureSession;          // session
    QTCaptureMovieFileOutput    *mCaptureMovieFileOutput;  // file output
    QTCaptureDeviceInput        *mCaptureVideoDeviceInput; // video input
    QTCaptureDeviceInput        *mCaptureAudioDeviceInput; // audio input
    int cnt;
}

-(id)init;

/**
 * Returns attached QTCaptureDevice objects that have video.
 * Includes video-only devices (QTMediaTypeVideo) and any
 * audio/video devices (QTMediaTypeMuxed).
 *
 * @return autoreleased array of video devices
 */
+(NSArray *)videoDevices;

/**
 * Returns default QTCaptureDevice object for video or nil 
 * if none found.
 */
+(QTCaptureDevice *)defaultDevice;

/**
 * Returns QTCaptureDevice matching name or nil if a device
 * matching the name cannot be found.
 */
+(QTCaptureDevice *)deviceNamed:(NSString *)name;

/**
 * Captures video from a device and saves it to a file
 */
+(BOOL)captureVideo:(QTCaptureDevice *)device toFile:(NSString *)path withDuration:(NSNumber *)recordSeconds withDelay:(NSNumber *)delaySeconds;

-(void)startSession:(QTCaptureDevice *)device toFile:(NSString *)path withDuration:(NSNumber *)recordSeconds;

-(void)dealloc;

@end