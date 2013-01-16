//
//  UIRecentPhotosTableViewController.m
//  Flickr Top Places
//
//  Created by Austin on 1/3/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "UIRecentPhotosTableViewController.h"
#import "FlickrFetcher.h"
#import "UIFlickrPhotoViewController.h"

@implementation UIRecentPhotosTableViewController

@synthesize recentPhotos = _recentPhotos;

- (void) setRecentPhotos:(NSArray*) photos {
    if (photos != _recentPhotos) {
        _recentPhotos = photos;
        [self.tableView reloadData];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.recentPhotos = [[[defaults objectForKey:@"flickr.topplaces.history"] reverseObjectEnumerator] allObjects];
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Photo View";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *place = [self.recentPhotos objectAtIndex:indexPath.row];
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSDictionary *photoDictionary = [self.recentPhotos objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    
    [[segue destinationViewController] setFlickrPhoto:photoDictionary];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIFlickrPhotoViewController* flickrPhotoViewController = [[self.splitViewController viewControllers] lastObject];
    
    if (flickrPhotoViewController) {
        [flickrPhotoViewController redrawPhoto:[self.recentPhotos objectAtIndex:indexPath.row]];
    }
}


@end
