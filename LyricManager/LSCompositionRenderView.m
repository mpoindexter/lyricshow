//
//  LSCompositionRenderView.m
//  LyricManager
//
//  Created by Michael Poindexter on 3/11/12.
//  Copyright (c) 2012 Michael Poindexter. All rights reserved. See LICENSE for copying details.
//

#import <OpenGL/CGLMacro.h>
#import "LSCompositionRenderView.h"


@implementation LSCompositionRenderView

@synthesize pixelBuffer = _pixelBuffer;
@synthesize model = _model;

- (void)_createContext
{
    NSOpenGLPixelFormatAttribute attributes[] = {
        NSOpenGLPFAAccelerated, 
        NSOpenGLPFANoRecovery, 
        NSOpenGLPFADoubleBuffer, 
        NSOpenGLPFADepthSize, 24,
        0};
    GLint swapInterval = 1;
    
    //Create the OpenGL context used to render the animation and attach it to the rendering view
    NSOpenGLPixelFormat* pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
    _glContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:nil];
    [_glContext setValues:&swapInterval forParameter:NSOpenGLCPSwapInterval];
    CGLContextObj cgl_ctx = [_glContext CGLContextObj];
    glGenTextures(1, &_texture);
}

- (id)initWithPixelBuffer:(NSOpenGLPixelBuffer*) pixelBuffer
{
    self = [super init];
    
    if (self != nil) {
        [self setPixelBuffer:pixelBuffer];
        [self _createContext];
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frameRect pixelBuffer:(NSOpenGLPixelBuffer*) pixelBuffer
{
    self = [super initWithFrame:frameRect];
    
    if (self != nil) {
        [self setPixelBuffer:pixelBuffer];
        [self _createContext];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self _createContext];
}

- (void)updateRendering
{
    CGLContextObj cgl_ctx = [_glContext CGLContextObj];
    GLint saveTextureName;
    
    //Save the currently bound texture
    glGetIntegerv(GL_TEXTURE_BINDING_RECTANGLE_EXT, &saveTextureName);
    
    //Bind the texture and update its contents
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _texture);
    [_glContext setTextureImageToPixelBuffer:_pixelBuffer colorBuffer:GL_FRONT];
    
    //Restore the previously bound texture
    glBindTexture(GL_TEXTURE_BINDING_RECTANGLE_EXT, saveTextureName);
    
    [self drawRect:[self frame]];
}

- (void)lockFocus
{
    NSOpenGLContext* context = _glContext;
    
    // make sure we are ready to draw
    [super lockFocus];
    
    // when we are about to draw, make sure we are linked to the view
    // It is not possible to call setView: earlier (will yield 'invalid drawable')
    if ([context view] != self) {
        [context setView:self];
    }
    
    // make us the current OpenGL context
    [context makeCurrentContext];
}

// this is called whenever the view changes (is unhidden or resized)
- (void)drawRect:(NSRect)frame {
    CGLContextObj cgl_ctx = [_glContext CGLContextObj]; 
    
    // inform the context that the view has been resized
    [_glContext update];
    
    glViewport(0, 0, frame.size.width, frame.size.height);
    
    float aspectRatio = frame.size.width / frame.size.height;
    float targetAspectRatio = _aspectRatio;    
    CGFloat w = 0;
    CGFloat h = 0;
    CGFloat t = 1.0;
    CGFloat l = -1.0;
    if (aspectRatio < targetAspectRatio) {
        w = 2.0;
        h = w * (aspectRatio / targetAspectRatio);
        t = 1.0 - ((2.0 - h) / 2);
    } else {
        h = 2.0;
        w = h * (targetAspectRatio / aspectRatio);
        l = -1.0 + ((2.0 - w) / 2);
    }
    
    //Clear background
    glClearColor(0.25, 0.25, 0.25, 0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //Configure projection matrix
    glMatrixMode(GL_PROJECTION_MATRIX);
    glLoadIdentity();
    glOrtho(-1.0, 1.0, -1.0, 1.0, 0, 0);
    
    //Configure modelview matrix
    glMatrixMode(GL_MODELVIEW_MATRIX);
    glLoadIdentity();
    
    if(_pixelBuffer != nil) {
        glEnable(GL_TEXTURE_RECTANGLE_EXT);
        glBindTexture(GL_TEXTURE_RECTANGLE_EXT, _texture);
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        
    } else {
        glColor3f(1.0, 1.0, 1.0);
    }
    
    //Draw textured quad
    glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0);
    glVertex3f(l, t - h, 0.0);
    glTexCoord2f((float)[_pixelBuffer pixelsWide], 0.0);
    glVertex3f(l + w, t - h, 0.0);
    glTexCoord2f((float)[_pixelBuffer pixelsWide], (float)[_pixelBuffer pixelsHigh]);
    glVertex3f(l + w, t, 0.0);
    glTexCoord2f(0.0, (float)[_pixelBuffer pixelsHigh]);
    glVertex3f(l, t, 0.0);
    glEnd();
    
    if(_pixelBuffer != nil) {
        glDisable(GL_TEXTURE_RECTANGLE_EXT);
    }
    
    [_glContext flushBuffer];
}

-(void) update
{
    [_glContext update];
}

// this tells the window manager that nothing behind our view is visible
-(BOOL) isOpaque 
{
    
    return YES;
}

- (CGFloat)aspectRatio
{
    return _aspectRatio;
}

- (void)setAspectRatio:(CGFloat)aspectRatio
{
    _aspectRatio = aspectRatio;
    [self setNeedsLayout:YES];
}

- (BOOL)acceptsFirstResponder
{
    return [self isInFullScreenMode];
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{       
    switch([theEvent keyCode]) {
        case 53: // esc
            [_model setFullscreen:NO];
            break;
        default:
            [super keyDown:theEvent];
    }
}

@end
