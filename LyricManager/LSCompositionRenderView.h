//
//  LSCompositionRenderView.h
//  LyricManager
//
//  Created by Michael Poindexter on 3/11/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <Cocoa/Cocoa.h>
#import "LSModel.h"

@interface LSCompositionRenderView : NSView
{
    CGFloat _aspectRatio;
    GLuint _texture;
    NSOpenGLContext* _glContext;
}

@property (assign) IBOutlet LSModel* model;
@property (retain) NSOpenGLPixelBuffer* pixelBuffer;
@property (assign) CGFloat aspectRatio;

- (id)initWithPixelBuffer:(NSOpenGLPixelBuffer*) pixelBuffer;
- (id)initWithFrame:(NSRect)frameRect pixelBuffer:(NSOpenGLPixelBuffer*) pixelBuffer;
- (void)updateRendering;

@end
