//
//  LSAppDelegate.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/4/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import "LSAppDelegate.h"

@implementation LSAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
