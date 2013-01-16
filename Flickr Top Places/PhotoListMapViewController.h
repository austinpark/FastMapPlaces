//
//  PhotoListMapViewController.h
//  FastMapPlace
//
//  Created by Austin on 1/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class PhotoListMapViewController;

@protocol PhotoListMapViewControllerDelegate <NSObject>

- (NSData*) mapViewController:(PhotoListMapViewController*)sender imageForAnnotation:(id<MKAnnotation>)annotation;
- (void) viewDetailDisclosure:(PhotoListMapViewController*)sender withImage:(id<MKAnnotation>)annotation;

@end

@interface PhotoListMapViewController : UIViewController
@property (nonatomic, strong) NSArray* annotations;
@property (nonatomic, weak) id<PhotoListMapViewControllerDelegate> delegate;

- (void) shouldZoom:(BOOL)zoom;

- (void) zoomToLocation:(CLLocationCoordinate2D)coordinate;

@end
