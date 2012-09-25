//
//  LSLyricFile.h
//  LyricManager
//
//  Created by Michael Poindexter on 3/12/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <Foundation/Foundation.h>
#import "LSLyricChunk.h"

@interface LSLyricFile : NSObject

@property (retain) NSURL* filePath;
@property (retain) NSString* fileName;
@property (retain) NSArray* chunks;

-(id)initWithFile:(NSURL*) file;

@end
