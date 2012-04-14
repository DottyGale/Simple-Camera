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
#import "UIImage+Resize.h"

static NSString * const kFlickrAVCaptureStreamPhotoSizePreviewThumbnail = @"preview";
static NSString * const kFlickrAVCaptureStreamPhotoSizeUploadThumbnail = @"upload";
static NSString * const kFlickrAVCaptureStreamPhotoSizeFull = @"full";

typedef NSString * FlickrAVCaptureStreamPhotoSize;

@interface FlickrAVCaptureStreamPhoto : NSObject {
    NSMutableDictionary *cachedBase64;
    UIImage *photo;
    CGSize previewThumbnailSize;
    CGSize uploadThumbnailSize;
}

@property (nonatomic, retain) UIImage *photo;

- (id) initWithPhoto:(UIImage *)thePhoto previewThumbnailSize:(CGSize)thePreviewSize uploadThumbnailSize:(CGSize)theUploadSize;
- (NSString *) base64DataForSize:(FlickrAVCaptureStreamPhotoSize)size;

@end

@implementation FlickrAVCaptureStreamPhoto

@synthesize photo;

- (id) initWithPhoto:(UIImage *)thePhoto previewThumbnailSize:(CGSize)thePreviewSize uploadThumbnailSize:(CGSize)theUploadSize {
    if (!(self = [super init])) {
        return nil;
    }
    
    cachedBase64 = [[NSMutableDictionary alloc] init];
    self.photo = thePhoto;
    
    previewThumbnailSize = thePreviewSize;
    uploadThumbnailSize = theUploadSize;
    
    return self;
}

- (void) dealloc {
    [cachedBase64 release];
    [photo release];
    [super dealloc];
}

- (NSString *) base64DataForSize:(FlickrAVCaptureStreamPhotoSize)size {
    NSString *cached = [cachedBase64 objectForKey:size];
    if (cached) { return cached; }

    CGFloat width;
    if ([size isEqualToString:kFlickrAVCaptureStreamPhotoSizePreviewThumbnail]) {
        width = previewThumbnailSize.width;
    } else if ([size isEqualToString:kFlickrAVCaptureStreamPhotoSizeUploadThumbnail]) {
        width = uploadThumbnailSize.width;
    }

    UIImage *thumbnail = [self.photo thumbnailImage:width transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationDefault];
    
    NSString *base64data = [NSString base64StringFromData:UIImageJPEGRepresentation(thumbnail, 1.0f)];
    [cachedBase64 setObject:base64data forKey:size];
    
    return base64data;
}

@end

@interface FlickrAVCaptureStream ()

@property (nonatomic, readonly) NSMutableArray *pendingPhotos;

@end

@implementation FlickrAVCaptureStream

- (void) capturePhoto:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString *captureCallback = [arguments pop];
    [processor capturePhotoWithBlock:^(UIImage *image) {
        
        FlickrAVCaptureStreamPhoto *photo = [[FlickrAVCaptureStreamPhoto alloc] initWithPhoto:image previewThumbnailSize:previewThumbnailSize uploadThumbnailSize:uploadThumbnailSize];
        [self.pendingPhotos addObject:photo];

        NSMutableDictionary* results = [NSMutableDictionary dictionary];

        [results setObject:[photo base64DataForSize:kFlickrAVCaptureStreamPhotoSizePreviewThumbnail] forKey:@"preview"];
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:results];
        
        NSString* js = [result toSuccessCallbackString:captureCallback];
        
        [self writeJavascript:js];
        
        [photo release];
    }];
}

- (void) endCapture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    [processor endCapture];
}

- (void) photosForUpload:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    NSString *uploadCallback = [[arguments pop] retain];
    
    // TODO: handle pagination from options
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:[pendingPhotos count]];
    for (FlickrAVCaptureStreamPhoto *photo in pendingPhotos) {
        [photos addObject:[photo base64DataForSize:kFlickrAVCaptureStreamPhotoSizeUploadThumbnail]];
    }
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:photos];
    NSString* js = [result toSuccessCallbackString:uploadCallback];
    
    [self writeJavascript:js];
    
    [photos release];
}

- (void) startCapture:(NSMutableArray *)arguments withDict:(NSMutableDictionary *)options {
    callback = [[arguments pop] retain];
    
    processor = [[FlickrStreamCaptureProcessor alloc] initWithCaptureStream:self parentViewController:self.viewController];
    processor.toolbarHeight = [[options objectForKey:@"toolbarHeight"] floatValue];
    
    NSDictionary *thumbDimensions = [options objectForKey:@"previewThumbnailDimensions"];
    
    previewThumbnailSize = CGSizeMake([[thumbDimensions objectForKey:@"width"] floatValue], [[thumbDimensions objectForKey:@"height"] floatValue]);

    thumbDimensions = [options objectForKey:@"uploadThumbnailDimensions"];
    uploadThumbnailSize = CGSizeMake([[thumbDimensions objectForKey:@"width"] floatValue], [[thumbDimensions objectForKey:@"height"] floatValue]);

    [processor startCapture];
}

- (void) dealloc {
    [callback release];
    [pendingPhotos release];
    [processor release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private Methods

- (NSMutableArray *) pendingPhotos {
    if (!pendingPhotos) {
        pendingPhotos = [[NSMutableArray alloc] init];
    }
    
    return pendingPhotos;
}


@end
