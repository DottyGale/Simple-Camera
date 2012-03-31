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

@class FlickrAVCaptureStream, FlickrStreamCaptureViewController;

@interface FlickrStreamCaptureProcessor : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession *captureSession;
    FlickrAVCaptureStream *captureStream;
    UIViewController *parentViewController;
    FlickrStreamCaptureViewController *viewController;
    AVCaptureVideoPreviewLayer *previewLayer;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) FlickrAVCaptureStream *captureStream;
@property (nonatomic, retain) UIViewController *parentViewController;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) FlickrStreamCaptureViewController *viewController;

- (id) initWithCaptureStream:(FlickrAVCaptureStream *)theCaptureStream parentViewController:(UIViewController *)parentController;
- (void) startCapture;

@end
