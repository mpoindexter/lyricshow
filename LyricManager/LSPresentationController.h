//
//  LSPresentationController.h
//  LyricManager
//
//  Created by Michael Poindexter on 3/11/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import "LSModel.h"
#import "LSCompositionRenderView.h"

@interface LSPresentationController : NSObject
{
    NSOpenGLContext* _pixelBufferContext;
    NSOpenGLPixelBuffer* _pixelBuffer;
    NSString* _compositionFile;
    NSScreen* _displayScreen;
    BOOL _fullscreen;
    QCRenderer* _renderer;
    NSTimer* _renderTimer;
    NSTimeInterval _startTime;
    QCCompositionParameterView* _parametersView;
    LSCompositionRenderView* _previewView;
    LSCompositionRenderView* _fullscreenView;
    BOOL _isPaused;
    float _aspectRatio;
}

@property (assign) NSScreen* displayScreen;
@property (assign) BOOL blankscreen;
@property (assign) IBOutlet LSModel* model;
@property (retain) IBOutlet LSCompositionRenderView* previewView;
@property (retain) IBOutlet QCCompositionParameterView* parametersView;

-(id)init;
-(void)setCompositionFile:(NSString*)file;
-(id<QCCompositionRenderer>)renderer;
-(void)pauseRendering;
-(void)resumeRendering;
-(void)setFullscreen:(BOOL)isFullscreen;
@end
