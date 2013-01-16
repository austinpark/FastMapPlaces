//
//  UITopPlacesTableViewController.m
//  Flickr Top Places
//
//  Created by Austin on 1/2/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "UITopPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoListMapViewController.h"
#import "FlickrPlaceAnnotation.h"
#import "UIPlaceTableViewController.h"

@interface UITopPlacesTableViewController() <PhotoListMapViewControllerDelegate>
@end

@implementation UITopPlacesTableViewController
@synthesize places = _places;

- (void) setPlaces:(NSArray *)places {
    if (places != _places) {
        _places = places;
        [self.tableView reloadData];
    }
}
- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    id mapBarButtonItem = self.navigationItem.rightBarButtonItem;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *sortedPhotos = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]];
        
        NSArray *places = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:sortedPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem = sender;
            [self.navigationItem setRightBarButtonItem:mapBarButtonItem animated:YES];
            self.places = places;
        });
    });
    dispatch_release(downloadQueue);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    id currentBarButtonItem = self.navigationItem.leftBarButtonItem;
    id mapBarButtonItem = self.navigationItem.rightBarButtonItem;
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *sortedPhotos = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:FLICKR_PLACE_NAME ascending:YES]];
        
        NSArray *places = [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:sortedPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.leftBarButtonItem = currentBarButtonItem;
            [self.navigationItem setRightBarButtonItem:mapBarButtonItem animated:YES];
            self.places = places;
        });
    });
    dispatch_release(downloadQueue);


    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *place = [self.places objectAtIndex:indexPath.row];
    NSString *placeName = [place objectForKey:FLICKR_PLACE_NAME];
    NSRange cityIndex = [placeName rangeOfString:@","];
    
    if (cityIndex.location == NSNotFound) {
        cell.textLabel.text = placeName;
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.text = [placeName substringToIndex:cityIndex.location];
        cell.detailTextLabel.text = [placeName substringFromIndex:cityIndex.location + 1];
    }
    return cell;
}

- (NSArray*) mapAnnotations:(NSArray*) places {
    NSMutableArray* annotations = [NSMutableArray arrayWithCapacity:[places count]];
    
    for (NSDictionary* place in places) {
        [annotations addObject:[FlickrPlaceAnnotation annotationForPlace:place]];
    }
    
    return annotations;

}

- (NSData*) mapViewController:(PhotoListMapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation {
    return nil;
}

- (void) fetchPhotos:(NSDictionary*) places inController:(UIPlaceTableViewController*) controller withTitle:(NSString*) title {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    id currentButtonItem = controller.navigationItem.leftBarButtonItem;
    id mapButtonItem = controller.navigationItem.rightBarButtonItem;
    [controller.navigationItem setRightBarButtonItem:nil];
    
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t photoListDownloadQueue = dispatch_queue_create("photoListDownload Queue", NULL);
    
    dispatch_async(photoListDownloadQueue, ^{
        NSArray* photoList = [FlickrFetcher photosInPlace:places maxResults:50];
        [controller setPhotoList:photoList withTitle:title];
        controller.navigationItem.leftBarButtonItem = currentButtonItem;
        [controller.navigationItem setRightBarButtonItem:mapButtonItem animated:YES];
    });
    
    dispatch_release(photoListDownloadQueue);

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Flickr PhotoList Map"]) {
        PhotoListMapViewController* placePhotosController = [segue destinationViewController];
        placePhotosController.delegate = self;
        [placePhotosController shouldZoom:NO];
        
        placePhotosController.annotations = [self mapAnnotations:self.places];

    } else if ([segue.identifier isEqualToString:@"Flickr PhotoList"]) {

        NSDictionary *placeDictionary = [self.places objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        UIPlaceTableViewController* placePhotosController = [segue destinationViewController];
        
        [self fetchPhotos:placeDictionary inController:placePhotosController withTitle:[sender textLabel].text];        
    }
}

- (void)viewDetailDisclosure:(PhotoListMapViewController *)sender withImage:(id<MKAnnotation>)annotation {
    FlickrPlaceAnnotation* placeAnnotation = (FlickrPlaceAnnotation*) annotation;
    
    UIPlaceTableViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoListViewController"];
    
    [self fetchPhotos:placeAnnotation.place inController:vc withTitle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
