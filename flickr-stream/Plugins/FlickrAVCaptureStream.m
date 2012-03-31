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

- (void) capture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    callback = [[arguments pop] retain];
    
    processor = [[FlickrStreamCaptureProcessor alloc] initWithCaptureStream:self parentViewController:self.viewController];
    [processor startCapture];
    
//    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"jpg"]];
//
//    NSMutableDictionary* results = [NSMutableDictionary dictionary];
//    [results setObject:[NSString base64StringFromData:data] forKey:@"photo"];
//    
//    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:results];
//    
//    NSString* js = [result toSuccessCallbackString:callback];
//    
//    [self writeJavascript:js];
}

- (void) dealloc {
    [callback release];
    [processor release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods


@end
