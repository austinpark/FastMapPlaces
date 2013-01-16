//
//  FlickrPhotoAnnotation.m
//  FastMapPlace
//
//  Created by Austin on 1/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotoAnnotation

@synthesize photo = _photo;

+ (FlickrPhotoAnnotation*)annotationForPhoto:(NSDictionary *)photo {
    FlickrPhotoAnnotation* annotation = [[FlickrPhotoAnnotation alloc] init];
    annotation.photo = photo;
    return annotation;
}

- (NSString*) title {
    return [self.photo objectForKey:FLICKR_PHOTO_TITLE];
}

- (NSString*) subtitle {
    NSDictionary *photoDescriptionDict = [self.photo objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    NSString* photoDescription = [photoDescriptionDict objectForKey:@"_content"];

    return photoDescription;
}

- (CLLocationCoordinate2D) coordinate {
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    
    return coordinate;
}

@end
