//
//  FlickrAVCaptureStream.h
//  flickr-stream
//
//  Created by Joshua Cohen on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef CORDOVA_FRAMEWORK
#import <CORDOVA/CDVPlugin.h>
#else
#import "CDVPlugin.h"
#endif

@class FlickrStreamCaptureProcessor;

@interface FlickrAVCaptureStream : CDVPlugin {
    NSString *callback;
    NSMutableArray *pendingPhotos;
    CGSize previewThumbnailSize;
    FlickrStreamCaptureProcessor *processor;
    CGSize uploadThumbnailSize;
}

- (void) capturePhoto:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void) endCapture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void) photosForUpload:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;
- (void) startCapture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

@end
