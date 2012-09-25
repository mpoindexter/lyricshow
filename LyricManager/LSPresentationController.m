//
//  LSPresentationController.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/11/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <OpenGL/CGLMacro.h>
#import "LSPresentationController.h"

@implementation LSPresentationController

@synthesize model = _model;
@synthesize blankscreen = _blankscreen;

+(void) initialize
{
    [LSPresentationController exposeBinding:@"displayScreen"];
    [LSPresentationController exposeBinding:@"compositionFile"];
    [LSPresentationController exposeBinding:@"fullscreen"];
    [LSPresentationController exposeBinding:@"blankscreen"];
}

-(void)_renderGLScene
{

    if (_previewView == nil || _startTime == 0.0 || _isPaused) {
        return;
    }
    NSTimeInterval elapsedTime = [NSDate timeIntervalSinceReferenceDate] - _startTime;

    CGLContextObj cgl_ctx = [_pixelBufferContext CGLContextObj];   
    if (_blankscreen) {
        glClearColor(0, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    } else {
        [_renderer renderAtTime:elapsedTime arguments:nil];
    }
    glFlush();
    
    [_previewView updateRendering];
    [_fullscreenView updateRendering];
}

-(void)_createRendererForScreen:(NSScreen*) targetScreen compositionFile:(NSString*) compositionFile copySettings:(BOOL)copySettings
{
    NSRect targetFrame = [targetScreen visibleFrame];
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAPixelBuffer,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADepthSize, 24,
        (NSOpenGLPixelFormatAttribute) 0
    };
    NSOpenGLPixelFormat* format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
    
    if (_pixelBuffer != nil) {
        [_pixelBuffer release];
    }
    
    //Create the OpenGL pBuffer to render into
    _pixelBuffer = [[NSOpenGLPixelBuffer alloc] initWithTextureTarget:GL_TEXTURE_RECTANGLE_EXT textureInternalFormat:GL_RGBA textureMaxMipMapLevel:0 pixelsWide:targetFrame.size.width pixelsHigh:targetFrame.size.height];
    
    if(_pixelBuffer == nil) {
        NSLog(@"Cannot create OpenGL pixel buffer");
        return;
    }
        
    if(_pixelBufferContext != nil) {
        [_pixelBufferContext release];
    }
    _pixelBufferContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
    if(_pixelBufferContext == nil) {
        NSLog(@"Cannot create OpenGL context");
        return;
    }
    [_pixelBufferContext setPixelBuffer:_pixelBuffer cubeMapFace:0 mipMapLevel:0 currentVirtualScreen:[_pixelBufferContext currentVirtualScreen]];
        
    QCRenderer* oldRenderer = _renderer;
    
    //Create the QuartzComposer Renderer with that OpenGL context and the specified composition file
    _renderer = [[QCRenderer alloc] initWithOpenGLContext:_pixelBufferContext pixelFormat:format file:compositionFile];
    if(_renderer == nil) {
        NSLog(@"Cannot create QCRenderer");
        return;
    }
    
    if(oldRenderer != nil) {
        if (copySettings) {
            [_renderer setInputValuesWithPropertyList:[oldRenderer propertyListFromInputValues]];
        }
        [oldRenderer release];
    }
    
    _startTime = [NSDate timeIntervalSinceReferenceDate];
    
    [_previewView setPixelBuffer:_pixelBuffer];
    [_fullscreenView setPixelBuffer:_pixelBuffer];
    
    if (_parametersView != nil) {
        [_parametersView setCompositionRenderer:_renderer];
    }
    
    [self _renderGLScene];
}

-(void)_startTimer
{
    _renderTimer = [[NSTimer timerWithTimeInterval:(1.0 / (NSTimeInterval)60) target:self selector:@selector(_renderGLScene) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSModalPanelRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_renderTimer forMode:NSEventTrackingRunLoopMode];
}

- (void)awakeFromNib
{
    [self _startTimer];
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        [self _startTimer];
    }
    return self;
}

-(void)pauseRendering
{
    _isPaused = YES;
}
-(void)resumeRendering
{
    BOOL wasPaused = _isPaused;
    _isPaused = NO;
    if (wasPaused) {
        [self _renderGLScene];
    }
}

-(id<QCCompositionRenderer>) renderer
{
    return _renderer;
}

-(NSScreen*) displayScreen
{
    return _displayScreen;
}

-(void) setDisplayScreen:(NSScreen *)displayScreen
{
    _displayScreen = displayScreen;
    if(_compositionFile != nil) {
        [self _createRendererForScreen:displayScreen compositionFile:_compositionFile copySettings:YES];
    }
    NSRect frame = [displayScreen visibleFrame];
    _aspectRatio = frame.size.width / frame.size.height;
    [_previewView setAspectRatio:_aspectRatio];
}

-(QCCompositionParameterView*) parametersView
{
    return _parametersView;
}

-(void) setParametersView:(QCCompositionParameterView *)parametersView
{
    _parametersView = parametersView;
    [_parametersView setCompositionRenderer:_renderer];
}

-(LSCompositionRenderView*) previewView
{
    return _previewView;
}

-(void) setPreviewView:(LSCompositionRenderView *)previewView
{
    _previewView = previewView;
    [_previewView setPixelBuffer:_pixelBuffer];
    [_previewView setAspectRatio:_aspectRatio];
}

-(void)setFullscreen:(BOOL)isFullscreen
{
    _fullscreen = isFullscreen;
    if (isFullscreen) {
        _fullscreenView = [[LSCompositionRenderView alloc] initWithPixelBuffer:_pixelBuffer];
        [_fullscreenView setModel:_model];
        [_fullscreenView setAspectRatio:_aspectRatio];
        [_fullscreenView 
         enterFullScreenMode:_displayScreen 
         withOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                      [NSNumber numberWithBool:NO], NSFullScreenModeAllScreens, 
                      nil]
         ];
    } else {
        [_fullscreenView exitFullScreenModeWithOptions:nil];
        [_fullscreenView release];
        _fullscreenView = nil;
    }
}

-(void)setCompositionFile:(NSString*)file
{
    BOOL copySettings = NO;
    if(_compositionFile != nil) {
        copySettings = [_compositionFile isEqualToString:file];
        if(_compositionFile != file) {
            [_compositionFile release];
        }
    }
    _compositionFile = [file retain];
    
    if(_displayScreen != nil) {
        [self _createRendererForScreen:_displayScreen compositionFile:_compositionFile copySettings:copySettings];
    }
}


@end
