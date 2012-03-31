//
//  FlickrStreamCaptureProcessor.h
//  flickr-stream
//
//  Created by Joshua Cohen on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKIT/UIKit.h>

@class FlickrAVCaptureStream;

@interface FlickrStreamCaptureProcessor : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *captureSession;
    FlickrAVCaptureStream *captureStream;
    UIViewController *parentViewController;
    NSMutableArray *pendingCaptures;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) FlickrAVCaptureStream *captureStream;
@property (nonatomic, retain) UIViewController *parentViewController;

- (id) initWithCaptureStream:(FlickrAVCaptureStream *)theCaptureStream parentViewController:(UIViewController *)parentController;

- (void) capturePhotoWithBlock:(void (^)(NSData *))completed;
- (void) endCapture;
- (void) startCapture;

@end
