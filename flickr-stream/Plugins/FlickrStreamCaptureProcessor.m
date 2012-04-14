//
//  FlickrStreamCaptureProcessor.m
//  flickr-stream
//
//  Created by Joshua Cohen on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrStreamCaptureProcessor.h"
#import "FlickrAVCaptureStream.h"

#import "UIImage+Resize.h"

#import <CoreVideo/CoreVideo.h>

CGFloat const kFlickrStreamDefaultThumbnailWidth = 32.0f;
CGFloat const kFlickrStreamDefaultThumbnailHeight = 32.0f;
CGFloat const kFlickrStreamDefaultToolbarHeight = 40.0f;
NSUInteger const kFlickrStreamPreviewLayerViewTag = 101;

@interface FlickrStreamCaptureProcessor ()

- (AVCaptureVideoPreviewLayer *) configureCaptureSession;
- (void) captureCompletedWithImage:(UIImage *)image;

@end

@implementation FlickrStreamCaptureProcessor

@synthesize captureSession, captureStream, parentViewController, thumbnailDimensions, toolbarHeight;

- (id) initWithCaptureStream:(FlickrAVCaptureStream *)theCaptureStream parentViewController:(UIViewController *)parentController {
    if (!(self = [super init])) {
        return nil;
    }
    
    self.captureStream = theCaptureStream;
    self.parentViewController = parentController;
    self.toolbarHeight = kFlickrStreamDefaultToolbarHeight;
    self.thumbnailDimensions = CGSizeMake(kFlickrStreamDefaultThumbnailWidth, kFlickrStreamDefaultThumbnailHeight);

    return self;
}

- (void) capturePhotoWithBlock:(void (^)(NSDictionary *))completed {
    if (!pendingCaptures) {
        pendingCaptures = [[NSMutableArray alloc] init];
    }
    
    [pendingCaptures addObject:[[completed copy] autorelease]];
}

- (void) endCapture {
    [[self.parentViewController.view viewWithTag:kFlickrStreamPreviewLayerViewTag] removeFromSuperview];
}

- (void) startCapture {
    AVCaptureVideoPreviewLayer *previewLayer = [self configureCaptureSession];

    
    CGRect parentBounds = self.parentViewController.view.bounds;
    parentBounds.size.height -= self.toolbarHeight;

    UIView *view = [[UIView alloc] initWithFrame:parentBounds];
    view.tag = kFlickrStreamPreviewLayerViewTag;

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
    
    [self performSelectorOnMainThread:@selector(captureCompletedWithImage:) withObject:[UIImage imageWithCGImage:newImage scale:1.0f orientation:UIImageOrientationRight] waitUntilDone:NO];
    
	CGImageRelease(newImage);
	
	/*We unlock the  image buffer*/
	CVPixelBufferUnlockBaseAddress(imageBuffer,0);
	
	[pool drain];
} 

#pragma mark -
#pragma mark Private Methods

- (void) captureCompletedWithImage:(UIImage *)image {
    void (^completed)(NSDictionary *) = [pendingCaptures pop];
    
    NSData *fullSizeData = UIImageJPEGRepresentation(image, 1.0f);
    
    UIImage *thumbnail = [image thumbnailImage:thumbnailDimensions.width transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
    
    NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 1.0f); 
    
    NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:fullSizeData, @"photo", thumbnailData, @"thumbnail", nil];
    
    completed(results);
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
