//
//  UIFlickrPhotoViewController.h
//  Flickr Top Places
//
//  Created by Austin on 1/3/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFlickrPhotoViewController : UIViewController

- (void) setFlickrPhoto:(NSDictionary*) flickrPhoto;
- (void) redrawPhoto:(NSDictionary*) newPhoto;
@end
