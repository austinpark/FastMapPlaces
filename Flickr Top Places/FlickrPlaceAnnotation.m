//
//  FlickrPlaceAnnotation.m
//  FastMapPlace
//
//  Created by Austin on 1/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FlickrPlaceAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrPlaceAnnotation

@synthesize place = _place;
+ (FlickrPlaceAnnotation*)annotationForPlace:(NSDictionary*)place {
    FlickrPlaceAnnotation* annotation = [[FlickrPlaceAnnotation alloc] init];
    annotation.place = place;
    return annotation;
}

- (NSString*) title {
    
    NSString *placeName = [self.place objectForKey:FLICKR_PLACE_NAME];
    NSRange cityIndex = [placeName rangeOfString:@","];
    
    if (cityIndex.location == NSNotFound) {
        return placeName;
    } else {
        return [placeName substringToIndex:cityIndex.location];
    }
}

- (NSString*) subtitle {
    NSString *placeName = [self.place objectForKey:FLICKR_PLACE_NAME];
    NSRange cityIndex = [placeName rangeOfString:@","];
    
    if (cityIndex.location == NSNotFound) {
        return @"";
    } else {
        return [placeName substringFromIndex:cityIndex.location + 1];
    }
}

- (CLLocationCoordinate2D) coordinate {
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    
    return coordinate;
}


@end
