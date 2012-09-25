//
//  LSLyricFile.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/12/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import "LSLyricFile.h"

@implementation LSLyricFile

@synthesize filePath;
@synthesize fileName;
@synthesize chunks;

-(id)initWithFile:(NSURL*) file
{
    self = [super init];
    
    if (self != nil) {
        [self setFilePath:file];
        [self setFileName:[file lastPathComponent]];
        NSError* error;
        NSString* data = [NSString stringWithContentsOfURL:file encoding:NSUTF8StringEncoding error:&error];
        if (data == nil) {
            return nil;
        }
        
        BOOL inChunk = NO;
        NSMutableArray* tempChunks = [[[NSMutableArray alloc] initWithCapacity:20] autorelease];
        NSArray* lines = [data componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        NSMutableString* chunkRawData = [NSMutableString stringWithCapacity:300];
        NSMutableString* chunkCookedData = [NSMutableString stringWithCapacity:300];
        for (int i = 0; i < [lines count]; i++) {
            NSString* line = [lines objectAtIndex:i];
            if ([line isEqualToString:@""]) {
                if (inChunk) {
                    LSLyricChunk* chunk = [[[LSLyricChunk alloc] initWithRawText:[NSString stringWithString:chunkRawData] displayText:[NSString stringWithString: chunkCookedData]] autorelease];
                    [tempChunks addObject:chunk];
                }
                [chunkCookedData setString:@""];
                [chunkRawData setString:@""];
                inChunk = NO;
            } else {
                inChunk = YES;
                [chunkRawData appendString: line];
                [chunkRawData appendString:@"\n"];
                if (![line hasPrefix:@"*"]) {
                    [chunkCookedData appendString:line];
                    [chunkCookedData appendString:@"\n"];
                }
                
            }
        }
        
        if (inChunk) {
            LSLyricChunk* chunk = [[[LSLyricChunk alloc] initWithRawText:[NSString stringWithString:chunkRawData] displayText:[NSString stringWithString: chunkCookedData]] autorelease];
            [tempChunks addObject:chunk];
        }
        
        [self setChunks:tempChunks];
    }
    return self;
}

@end
