//
//  FlickrAVCaptureStream.m
//  flickr-stream
//
//  Created by Joshua Cohen on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrAVCaptureStream.h"
#import "FlickrStreamCaptureProcessor.h"
#import "NSString+NSStringAdditions.h"

@interface FlickrAVCaptureStream ()

@end

@implementation FlickrAVCaptureStream

- (void) capturePhoto:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString *captureCallback = [arguments pop];
    [processor capturePhotoWithBlock:^(NSData *photoData) {
        NSMutableDictionary* results = [NSMutableDictionary dictionary];
        [results setObject:[NSString base64StringFromData:photoData] forKey:@"photo"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:results];
        
        NSString* js = [result toSuccessCallbackString:captureCallback];
        
        [self writeJavascript:js];
    }];
}

- (void) startCapture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    callback = [[arguments pop] retain];
    
    processor = [[FlickrStreamCaptureProcessor alloc] initWithCaptureStream:self parentViewController:self.viewController];
    [processor startCapture];
}

- (void) dealloc {
    [callback release];
    [processor release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods


@end
