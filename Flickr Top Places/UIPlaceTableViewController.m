//
//  UIPlaceTableViewController.m
//  Flickr Top Places
//
//  Created by Austin on 1/3/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "UIPlaceTableViewController.h"
#import "UIFlickrPhotoViewController.h"
#import "FlickrFetcher.h"
#import "PhotoListMapViewController.h"
#import "FlickrPhotoAnnotation.h"

@interface UIPlaceTableViewController() <PhotoListMapViewControllerDelegate>
@property (nonatomic, strong) NSString* photoTitle;
@end

@implementation UIPlaceTableViewController

@synthesize photoList = _photoList;
@synthesize photoTitle = _photoTitle;

- (void) setPhotoList:(NSArray *)photoList {
    [self setPhotoList:photoList withTitle:nil];
}

- (void) setPhotoList:(NSArray *)photoList withTitle:(NSString *)title {
    
    if (photoList != _photoList) {
        _photoList = photoList;
        [self.tableView reloadData];
    }
    
    if (_photoTitle != title) {
        _photoTitle = title;
    }    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photoList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photos in Place";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *place = [self.photoList objectAtIndex:indexPath.row];
    NSString *photoTitle = [place objectForKey:FLICKR_PHOTO_TITLE];
    NSDictionary *photoDescriptionDict = [place objectForKey:FLICKR_PHOTO_DESCRIPTION];
    
    NSString* photoDescription = [photoDescriptionDict objectForKey:@"_content"];
    
    if (photoTitle && ![photoTitle isEqualToString:@""]) {
        cell.textLabel.text = photoTitle;
        cell.detailTextLabel.text = photoDescription;
    } else if (photoDescription && ![photoDescription isEqualToString:@""]) {
        cell.textLabel.text = photoDescription;
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.text = @"Uknown";
        cell.detailTextLabel.text = @"";        
    }
     
    return cell;
}

- (NSArray*) mapAnnotations:(NSArray*) photos {
    NSMutableArray* annotations = [NSMutableArray arrayWithCapacity:[photos count]];
    
    for (NSDictionary* photo in photos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    
    return annotations;
    
}

- (NSData*) mapViewController:(PhotoListMapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation {
    
    FlickrPhotoAnnotation* fpa = (FlickrPhotoAnnotation*)annotation;
    
    NSData* imageBinary = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare]];
    
    return imageBinary;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Flickr PhotoList Segue"]) {
        PhotoListMapViewController* placePhotosController = [segue destinationViewController];
        placePhotosController.delegate = self;
        [placePhotosController shouldZoom:YES];
        placePhotosController.annotations = [self mapAnnotations:self.photoList];
        
    } else {
        NSDictionary *photoDictionary = [self.photoList objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        
        [[segue destinationViewController] setFlickrPhoto:photoDictionary];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIFlickrPhotoViewController* flickrPhotoViewController = [[self.splitViewController viewControllers] lastObject];
    
    if (flickrPhotoViewController) {
        [flickrPhotoViewController redrawPhoto:[self.photoList objectAtIndex:indexPath.row]];
    }
}

- (void) viewDetailDisclosure:(PhotoListMapViewController *)sender withImage:(id<MKAnnotation>)annotation {
    FlickrPhotoAnnotation* photoAnnotation = (FlickrPhotoAnnotation*)annotation;
    NSDictionary* photo = photoAnnotation.photo;
    
    UIFlickrPhotoViewController* vc = [[self.splitViewController viewControllers] lastObject];
    
    if (vc) {
        [vc redrawPhoto:photo];
    } else {
    
        vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FlickrPhotoImageView"];
        
        [vc setFlickrPhoto:photo];
            
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
