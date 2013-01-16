//
//  UIFlickrPhotoViewController.m
//  Flickr Top Places
//
//  Created by Austin on 1/3/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "UIFlickrPhotoViewController.h"
#import "FlickrFetcher.h"
#import "ImageCache.h"

@interface UIFlickrPhotoViewController() <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSDictionary* photo;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinning;

@end

@implementation UIFlickrPhotoViewController
@synthesize imageView = _imageview;
@synthesize scrollView = _scrollView;
@synthesize photo = _photo;
@synthesize toolbar = _toolbar;
@synthesize spinning = _spinning;

- (void) setFlickrPhoto:(NSDictionary*) flickrPhoto {
    if (self.photo != flickrPhoto) {
        self.photo = flickrPhoto;
    }
}

- (NSData*) downloadImage {
    
    NSData* imageBinary = [ImageCache get:[self.photo objectForKey:FLICKR_PHOTO_ID]];
    
    //Retrieve it from Flickr.
    if (!imageBinary) {    
        imageBinary = [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]];
    }
    
    return imageBinary;
}

- (void) adjustViewForImage:(NSData*) imageBinary {
    self.imageView.image = [UIImage imageWithData:imageBinary];
    
    self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    self.scrollView.zoomScale = 1;
    
    self.scrollView.contentSize = self.imageView.image.size;
    
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);    
}

- (void) zoomImageToFitIntoView {
    float widthRatio = self.view.bounds.size.width / self.imageView.image.size.width;
    
    float heightRatio = self.view.bounds.size.height / self.imageView.image.size.height;
    
    self.scrollView.zoomScale = MAX(widthRatio, heightRatio);
}


- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
    self.splitViewController.delegate = self;
    
}

- (void) viewWillLayoutSubviews {
    [self zoomImageToFitIntoView];
}


- (void) persistPhoto {
    
    if (!self.photo) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* recentlyViewedPhotos = [[defaults objectForKey:@"flickr.topplaces.history"] mutableCopy];
    
    if (!recentlyViewedPhotos) recentlyViewedPhotos = [NSMutableArray array];
    
    if (recentlyViewedPhotos.count > 50) {
        [recentlyViewedPhotos removeObjectAtIndex:0];
    }
    
    NSString* photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
    
    for (int i = 0; i < recentlyViewedPhotos.count; i++) {
        NSDictionary* photo = [recentlyViewedPhotos objectAtIndex:i];
        if ([[photo objectForKey:FLICKR_PHOTO_ID] isEqualToString:photoID]) {
            [recentlyViewedPhotos removeObject:photo];
            break;
        }
    }
    
    [recentlyViewedPhotos addObject:self.photo];
    
    [defaults setObject:recentlyViewedPhotos forKey:@"flickr.topplaces.history"];
    
    [defaults synchronize];
    
    

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setSpinning:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) refresh {
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    [self.spinning startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("photo_download", NULL);
    dispatch_async(downloadQueue, ^{
        NSString* photoID = [self.photo objectForKey:FLICKR_PHOTO_ID];
        NSData* imageBinary = [self downloadImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self persistPhoto];
            [self adjustViewForImage:imageBinary];
            [self zoomImageToFitIntoView];
            if (imageBinary) [ImageCache put:photoID withData:imageBinary];
            [spinner stopAnimating];
            [self.navigationItem setRightBarButtonItem:nil];
            [self.spinning stopAnimating];
        });
    });
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.photo) {
        [self refresh];
    }
    
}

- (void) redrawPhoto:(NSDictionary*) newPhoto {
    self.photo = newPhoto;
    
    [self refresh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (BOOL) splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void) splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Photo List";
    
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems insertObject:barButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
}

- (void) splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    [toolbarItems removeObject:barButtonItem];
    self.toolbar.items = toolbarItems;
}

@end
