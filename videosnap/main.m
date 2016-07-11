//
//  main.m
//  videosnap
//
//  Created by Matthew Hutchinson on 10/07/2016.
//  Copyright © 2016 Matthew Hutchinson. All rights reserved.
//

#import "VideoSnap.h"


int main(int argc, const char * argv[]) {
	// convert C argv values array to NSArray
	NSMutableArray *args = [[NSMutableArray alloc] initWithCapacity: argc];
	for (int i = 0; i < argc; i++) {
		[args addObject: [NSString stringWithCString: argv[i] encoding:NSASCIIStringEncoding]];
	}

	return [VideoSnap processArgs: args];
}