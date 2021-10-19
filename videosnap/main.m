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
 * main
 */
int main(int argc, const char * argv[]) {

	isInterrupted = NO;
	
	// setup int handler for Ctrl+C cancelling
	signal(SIGINT, &SIGINT_handler);

	// C args as NSArray
	NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity: argc];
	for (int i = 0; i < argc; i++) {
		[args addObject: [NSString stringWithCString: argv[i] encoding: NSUTF8StringEncoding]];
	}
    
    // debugging some args
    //[args addObject: @"-v"];
    //[args addObject: @"-l"];
    
    videoSnap = [[VideoSnap alloc] initWithVerbosity:([args indexOfObject:@"-v"] != NSNotFound)];

    return [videoSnap processArgs: args];
}
