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

@interface FlickrAVCaptureStream : CDVPlugin {
    NSString *callback;
}

- (void) capture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options;

@end
