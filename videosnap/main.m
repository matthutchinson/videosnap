//
//  main.m
//  videosnap
//
//  Created by Matthew Hutchinson on 10/07/2016.
//  Copyright © 2020 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"

/**
 * C globals
 */

BOOL isInterrupted;
VideoSnap *videoSnap;
NSArray *initArgs;

/**
 * signal interrupt handler
 */
void SIGINT_handler(int signum) {
    if (!isInterrupted && [videoSnap isRecording]) {
        isInterrupted = YES;
        [videoSnap stopRecording:signum];
    } else {
        exit(0);
    }
}

/**
 * signal interrupt handler
 */
void SIGSTP_handler(int signum) {
    if (![videoSnap isRecording]) {
        return;
    }
    
    [videoSnap togglePauseRecording:signum];
}

/**
 * signal interrupt handler
 */
void SIGQUIT_handler(int signum) {
    if (![videoSnap isRecording]) {
        return;
    }
    
    [videoSnap stopRecording:signum];
    videoSnap     = [[VideoSnap alloc] init];
    [videoSnap processArgs: initArgs];
}

/**
 * main
 */
int main(int argc, const char * argv[]) {

    isInterrupted = NO;
    videoSnap     = [[VideoSnap alloc] init];

    // setup int handler for Ctrl+C cancelling
    signal(SIGINT, &SIGINT_handler);
    signal(SIGTSTP, &SIGSTP_handler);
    signal(SIGQUIT, &SIGQUIT_handler);
    
    // convert C argv values array to NSArray
    NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity: argc];
    for (int i = 0; i < argc; i++) {
        [args addObject: [NSString stringWithCString: argv[i] encoding:NSUTF8StringEncoding]];
    }
    
    // opt in to see connected iOS screen devices
    @autoreleasepool {
        CMIOObjectPropertyAddress prop = {
            kCMIOHardwarePropertyAllowScreenCaptureDevices,
            kCMIOObjectPropertyScopeGlobal,
            kCMIOObjectPropertyElementMaster
        };
        UInt32 allow = 1;
        CMIOObjectSetPropertyData(kCMIOObjectSystemObject, &prop, 0, NULL, sizeof(allow), &allow);
    }
    initArgs = args;
    return [videoSnap processArgs: args];
}
