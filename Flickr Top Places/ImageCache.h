//
//  ImageCache.h
//  FastMapPlace
//
//  Created by Austin on 1/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject

#define MAXIMUM_SIZE 5*1024*1024

+ (NSData*) get:(NSString*)key;
+ (void) put:(NSString*) key withData:(NSData*) data;
@end
