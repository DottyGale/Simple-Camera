//
//  FlickrStreamCaptureProcessor.m
//  flickr-stream
//
//  Created by Joshua Cohen on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrStreamCaptureProcessor.h"
#import "FlickrAVCaptureStream.h"
#import "FlickrStreamCaptureViewController.h"

#import <CoreVideo/CoreVideo.h>

@interface FlickrStreamCaptureProcessor ()

- (void) configureCaptureSession;
- (void) showOverlay;

@end

@implementation FlickrStreamCaptureProcessor

@synthesize captureSession, captureStream, parentViewController, previewLayer, viewController;

- (id) initWithCaptureStream:(FlickrAVCaptureStream *)theCaptureStream parentViewController:(UIViewController *)parentController {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.captureStream = theCaptureStream;
    self.parentViewController = parentController;

    return self;
}

- (void) startCapture {
    [self configureCaptureSession];
    self.viewController = [[[FlickrStreamCaptureViewController alloc] initWithCaptureProcessor:self] autorelease];
    [self performSelector:@selector(showOverlay) withObject:nil afterDelay:1];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return true;
}

- (void) dealloc {
    [captureStream release];
    [captureSession release];
    [parentViewController release];
    [previewLayer release];
    [viewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

- (void) configureCaptureSession {
    NSError *error = nil;
    
    self.captureSession = [[[AVCaptureSession alloc] init] autorelease];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"unable to obtain video capture device");
        return;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"unable to obtain video capture device input");
        return;
    }
    
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    if (!output) {
        NSLog(@"unable to obtain video capture output");
        return;
    }
    
    NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = videoOutputSettings;
    
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    if (![captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        NSLog(@"unable to preset medium quality video capture");
        return;
    }
    
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    } else {
        NSLog(@"unable to add video capture device input to session");
        return;
    }
    
    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
    } else {
        NSLog(@"unable to add video capture output to session");
        return;
    }
    
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    
    [captureSession performSelector:@selector(startRunning) withObject:nil afterDelay:0];
}

- (void) showOverlay {
    [self.parentViewController presentModalViewController:self.viewController animated:NO];
}

@end
