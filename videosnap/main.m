//
//  main.m
//  videosnap
//
//  Created by Matthew Hutchinson
//

#import "VideoSnap.h"

/**
 * C globals
 */

BOOL isInterrupted;
VideoSnap *videoSnap;

/**
 * signal interrupt handler Ctrl+c
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
 * signal interrupt handler Ctrl+z
 */
void SIGSTP_handler(int signum) {
    if ([videoSnap isRecording]) {
        [videoSnap togglePauseRecording:signum];
    }
}

/**
 * main
 */
int main(int argc, const char * argv[]) {
	isInterrupted = NO;
	
	// setup int handlers
    // Ctrl+C cancels
    // Ctrl+Z pause/resume
	signal(SIGINT, &SIGINT_handler);
    signal(SIGTSTP, &SIGSTP_handler);

	// C args as NSArray
	NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity: argc];
	for (int i = 0; i < argc; i++) {
		[args addObject: [NSString stringWithCString: argv[i] encoding: NSUTF8StringEncoding]];
	}
    
    videoSnap = [[VideoSnap alloc]
                 initWithVerbosity:([args indexOfObject:@"-v"] != NSNotFound)];

    return [videoSnap processArgs: args];
}
