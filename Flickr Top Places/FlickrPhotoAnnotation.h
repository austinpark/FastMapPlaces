//
//  FlickrPhotoAnnotation.h
//  FastMapPlace
//
//  Created by Austin on 1/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotoAnnotation : NSObject <MKAnnotation>

+ (FlickrPhotoAnnotation*)annotationForPhoto:(NSDictionary*)photo;

@property (nonatomic, strong) NSDictionary* photo;
@end
