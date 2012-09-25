//
//  LSLyricChunk.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/12/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import "LSLyricChunk.h"

@implementation LSLyricChunk

@synthesize rawText;
@synthesize displayText;

-(id)initWithRawText:(NSString*)rawText displayText:(NSString*)displayText
{
    self = [super init];
    if (self != nil) {
        [self setRawText:rawText];
        [self setDisplayText:displayText];
    }
    return self;
}
@end
