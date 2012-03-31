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

- (void) loadView {
//    CGRect parentFrame = self.processor.parentViewController.view.frame;
//    parentFrame.size.height -= 40.0f;

    CGRect parentFrame = CGRectMake(0, 0, 320, 440);
    self.view = [[[UIView alloc] initWithFrame:parentFrame] autorelease];
    self.view.backgroundColor = [UIColor greenColor];

//    AVCaptureVideoPreviewLayer *previewLayer = self.processor.previewLayer;
//
//    previewLayer.frame = self.view.bounds;
//    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//
//    if ([previewLayer isOrientationSupported]) {
//        [previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
//    }
//
//    [self.view.layer insertSublayer:previewLayer below:[[self.view.layer sublayers] objectAtIndex:0]];
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
