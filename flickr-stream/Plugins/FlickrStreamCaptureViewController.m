//
//  FlickrStreamCaptureViewController.m
//  flickr-stream
//
//  Created by Joshua Cohen on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrStreamCaptureViewController.h"
#import "FlickrStreamCaptureProcessor.h"

#import <AVFoundation/AVFoundation.h>

@interface FlickrStreamCaptureViewController ()

- (void) showOverlay;

@end

@implementation FlickrStreamCaptureViewController

@synthesize processor;

- (id) initWithCaptureProcessor:(FlickrStreamCaptureProcessor *)captureProcessor {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.processor = captureProcessor;
    
    return self;
}

- (void)loadView {
    self.view = [[[UIView alloc] initWithFrame: self.processor.parentViewController.view.frame] autorelease];
    
    AVCaptureVideoPreviewLayer* previewLayer = self.processor.previewLayer;
    previewLayer.frame = self.view.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    if ([previewLayer isOrientationSupported]) {
        [previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }
    
    [self.view.layer insertSublayer:previewLayer below:[[self.view.layer sublayers] objectAtIndex:0]];
}

- (void) dealloc {
    [processor release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

- (void) showOverlay {
    [self.parentViewController presentModalViewController:self animated:NO];
}

@end
