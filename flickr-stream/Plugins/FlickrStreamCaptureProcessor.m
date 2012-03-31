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
- (void) captureCompletedWithData:(NSData *)data;

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
    if (!pendingCaptures) {
        pendingCaptures = [[NSMutableArray alloc] init];
    }
    
    [pendingCaptures addObject:[[completed copy] autorelease]];
}

- (void) endCapture {
    [[self.parentViewController.view viewWithTag:834] removeFromSuperview];
}

- (void) startCapture {
    AVCaptureVideoPreviewLayer *previewLayer = [self configureCaptureSession];
    
    CGRect parentFrame = self.parentViewController.view.frame;
    parentFrame.origin.y = 0.0f;
    parentFrame.size.height -= 40.0f; // TODO: presumably toolbar size will vary on iPad

    UIView *view = [[UIView alloc] initWithFrame:parentFrame];
    view.tag = 834;

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
#pragma mark AVCaptureSession delegate
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection { 

    if (![pendingCaptures count]) { return; }
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    
    /* Lock the image buffer */
    CVPixelBufferLockBaseAddress(imageBuffer,0); 
    
    /* Get information about the image */
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer);  
    
    /* Create a CGImageRef from the CVImageBufferRef */
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext); 
	
    /* We release some components */
    CGContextRelease(newContext); 
    CGColorSpaceRelease(colorSpace);
    
    
    UIImage *image = [UIImage imageWithCGImage:newImage];
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
	
    [self performSelectorOnMainThread:@selector(captureCompletedWithData:) withObject:data waitUntilDone:NO];
    
	CGImageRelease(newImage);
	
	/*We unlock the  image buffer*/
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	[pool drain];
} 

#pragma mark -
#pragma mark Private Methods

- (void) captureCompletedWithData:(NSData *)data {
    void (^completed)(NSData *) = [pendingCaptures pop];
    completed((NSData *)data);
}

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
    
	dispatch_queue_t queue;

	queue = dispatch_queue_create("cameraQueue", NULL);
	[output setSampleBufferDelegate:self queue:queue];

	dispatch_release(queue);
    
    if (![captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        NSLog(@"unable to preset medium quality video capture");
        return nil;
    }
    
    captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
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
