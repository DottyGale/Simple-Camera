//
//  FlickrStreamCaptureViewController.h
//  flickr-stream
//
//  Created by Joshua Cohen on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrStreamCaptureProcessor;

@interface FlickrStreamCaptureViewController : UIViewController {
    FlickrStreamCaptureProcessor *processor;
}

@property (nonatomic, retain) FlickrStreamCaptureProcessor *processor;

- (id) initWithCaptureProcessor:(FlickrStreamCaptureProcessor *)processor;

@end
