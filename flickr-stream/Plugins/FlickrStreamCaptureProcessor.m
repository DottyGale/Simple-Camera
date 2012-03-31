//
//  FlickrStreamCaptureProcessor.m
//  flickr-stream
//
//  Created by Joshua Cohen on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrStreamCaptureProcessor.h"
#import "FlickrAVCaptureStream.h"

#import <CoreVideo/CoreVideo.h>

@interface FlickrStreamCaptureProcessor ()

- (AVCaptureVideoPreviewLayer *) configureCaptureSession;

@end

@implementation FlickrStreamCaptureProcessor

@synthesize captureSession, captureStream, parentViewController;

- (id) initWithCaptureStream:(FlickrAVCaptureStream *)theCaptureStream parentViewController:(UIViewController *)parentController {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.captureStream = theCaptureStream;
    self.parentViewController = parentController;

    return self;
}

- (void) capturePhotoWithBlock:(void (^)(NSData *))completed {
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"]];
    completed(data);
}

- (void) startCapture {
    AVCaptureVideoPreviewLayer *previewLayer = [self configureCaptureSession];
    
    CGRect parentFrame = self.parentViewController.view.frame;
    parentFrame.origin.y = 0.0f;
    parentFrame.size.height -= 40.0f; // TODO: presumably toolbar size will vary on iPad

    UIView *view = [[[UIView alloc] initWithFrame:parentFrame] autorelease];

    previewLayer.frame = view.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    if ([previewLayer isOrientationSupported]) {
        [previewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }

    [view.layer insertSublayer:previewLayer below:[[view.layer sublayers] objectAtIndex:0]];
    
    [self.parentViewController.view addSubview:view];
    [view release];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return true;
}

- (void) dealloc {
    [captureStream release];
    [captureSession release];
    [parentViewController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

- (AVCaptureVideoPreviewLayer *) configureCaptureSession {
    NSError *error = nil;
    
    self.captureSession = [[[AVCaptureSession alloc] init] autorelease];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"unable to obtain video capture device");
        return nil;
    }
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"unable to obtain video capture device input");
        return nil;
    }
    
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    if (!output) {
        NSLog(@"unable to obtain video capture output");
        return nil;
    }
    
    NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    output.alwaysDiscardsLateVideoFrames = YES;
    output.videoSettings = videoOutputSettings;
    
    [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    if (![captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        NSLog(@"unable to preset medium quality video capture");
        return nil;
    }
    
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    if ([captureSession canAddInput:input]) {
        [captureSession addInput:input];
    } else {
        NSLog(@"unable to add video capture device input to session");
        return nil;
    }
    
    if ([captureSession canAddOutput:output]) {
        [captureSession addOutput:output];
    } else {
        NSLog(@"unable to add video capture output to session");
        return nil;
    }
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    
    [captureSession performSelector:@selector(startRunning) withObject:nil afterDelay:0];
    
    return previewLayer;
}

@end
