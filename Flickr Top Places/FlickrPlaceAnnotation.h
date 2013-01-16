//
//  FlickrPlaceAnnotation.h
//  FastMapPlace
//
//  Created by Austin on 1/11/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface FlickrPlaceAnnotation : NSObject
+ (FlickrPlaceAnnotation*)annotationForPlace:(NSDictionary*)place;

@property (nonatomic, strong) NSDictionary* place;

@end
