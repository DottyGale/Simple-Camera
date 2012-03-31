//
//  FlickrAVCaptureStream.m
//  flickr-stream
//
//  Created by Joshua Cohen on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrAVCaptureStream.h"
#import "NSString+NSStringAdditions.h"

#import <AVFoundation/AVFoundation.h>

@interface FlickrAVCaptureStream ()

- (void) configureCaptureSession;

@end

@implementation FlickrAVCaptureStream

- (void) capture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    callback = [[arguments pop] retain];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"]];

    NSMutableDictionary* results = [NSMutableDictionary dictionary];
    [results setObject:[NSString base64StringFromData:data] forKey:@"photo"];
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:results];
    
    NSString* js = [result toSuccessCallbackString:callback];
    
    [self writeJavascript:js];
}

- (void) dealloc {
    [callback release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

- (void) configureCaptureSession {
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    if (videoInput) {
        [captureSession addInput:videoInput];
    } else {
        // TODO: invoke error callback
    }
    
    AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession];
}

@end
