//
//  PhotoListMapViewController.m
//  FastMapPlace
//
//  Created by Austin on 1/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PhotoListMapViewController.h"
#import <MapKit/MapKit.h>

@interface PhotoListMapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) BOOL zoom;

@end

@implementation PhotoListMapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize zoom = _zoom;

- (void) updateMapView {
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

- (void) setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    
    [self updateMapView];	
}

- (void) setAnnotations:(NSArray *)annotations {
    _annotations = annotations;
    [self updateMapView];
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    dispatch_queue_t imageFetchQ = dispatch_queue_create("mapannotationimage", NULL);
    
    dispatch_async(imageFetchQ, ^{
        NSData* imageBinary = [self.delegate mapViewController:self imageForAnnotation:view.annotation];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage* image = [UIImage imageWithData:imageBinary];
            if (image) {
                [(UIImageView*)view.leftCalloutAccessoryView setImage:image];
            }
        });
    });
    
    dispatch_release(imageFetchQ);
}

- (void) shouldZoom:(BOOL)zoom {
    self.zoom = zoom;
}

- (void) zoomToLocation:(CLLocationCoordinate2D)coordinate {
    if (self.zoom) {
        MKCoordinateRegion region;
        region.center = coordinate;
        region.span = MKCoordinateSpanMake(0.1, 0.1);
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:YES];
    }
}

- (void) zoomAmongAnnotations:(NSArray*) annotations {
    if (self.zoom) {
        double leftMostLatitude = -100000;
        double bottomMostLongitute = -100000;
        double rightMostLatitude = 100000;
        double topMostLongitude = 100000;
        for (id<MKAnnotation> annotation in annotations) {
            
            if (annotation.coordinate.latitude > leftMostLatitude) {
                leftMostLatitude = annotation.coordinate.latitude;
            }
            
            if (annotation.coordinate.latitude < rightMostLatitude) {
                rightMostLatitude = annotation.coordinate.latitude;
            }
            
            if (annotation.coordinate.longitude > bottomMostLongitute) {
                bottomMostLongitute = annotation.coordinate.longitude;
            }
            
            if (annotation.coordinate.longitude < topMostLongitude) {
                topMostLongitude = annotation.coordinate.longitude;
            }
        }
        NSLog(@"(%g, %g), (%g, %g)", leftMostLatitude, topMostLongitude, rightMostLatitude, bottomMostLongitute);
        
        CLLocationCoordinate2D center;
        center.latitude = (rightMostLatitude + leftMostLatitude) / 2;
        center.longitude = (bottomMostLongitute + topMostLongitude) / 2;
        
        CLLocation* leftTop = [[CLLocation alloc] initWithLatitude:leftMostLatitude longitude:topMostLongitude];
        CLLocation* rightBottom = [[CLLocation alloc] initWithLatitude:rightMostLatitude longitude:bottomMostLongitute];
        
        CLLocationDistance meters = [rightBottom distanceFromLocation:leftTop];
    
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, meters, meters);
        region = [self.mapView regionThatFits:region];
        [self.mapView setRegion:region animated:YES];
    }
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [self.delegate viewDetailDisclosure:self withImage:view.annotation];
}

- (MKAnnotationView*) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView* aView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.animatesDrop = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.rightCalloutAccessoryView = button;
    } else {
        aView.annotation = annotation;
    }
    
    [(UIImageView*)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self zoomAmongAnnotations:self.annotations];
//    id<MKAnnotation>annotation = [self.annotations lastObject];
//    [self zoomToLocation:annotation.coordinate];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
