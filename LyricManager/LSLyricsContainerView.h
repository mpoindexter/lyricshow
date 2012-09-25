//
//  LSLyricsContainerView.h
//  LyricManager
//
//  Created by Michael Poindexter on 3/5/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <Cocoa/Cocoa.h>
#import "LSModel.h"

@interface LSLyricsContainerView : NSView  {
    
@private NSTextView* _activeView;
@private LSLyricFile* _lyrics;
    
}

@property (assign) IBOutlet LSModel* model;
@property (assign) LSLyricFile* lyrics;

@end
