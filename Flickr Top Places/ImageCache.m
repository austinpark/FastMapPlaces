//
//  ImageCache.m
//  FastMapPlace
//
//  Created by Austin on 1/14/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

static NSURL* cachesURL;
static NSArray* fileProperties;

+ (NSFileManager*) fileManager {
   return [[NSFileManager alloc] init];
}

+ (NSURL*) cacheUrl {
    if (!cachesURL) {
        NSArray* caches = [[[self class] fileManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        cachesURL = [caches lastObject];
    }
    
    return cachesURL;
}

+ (NSArray*) fileProperties {
    
    if (!fileProperties) {
        fileProperties = [NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey, NSURLCreationDateKey, nil];
    }
    
    return fileProperties;
}

+ (NSURL*) getUrl:(NSString*) key {
    
    return [NSURL URLWithString:key relativeToURL:[ImageCache cacheUrl]];
}

+ (void) trimeCache {
    NSFileManager* fileManager = [[self class] fileManager];
    
    NSArray *URLsInCache = [NSArray arrayWithArray:[fileManager contentsOfDirectoryAtURL:[ImageCache cacheUrl] includingPropertiesForKeys:[ImageCache fileProperties] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil]];

    int cacheSize = 0;
    
    for (NSURL* url in URLsInCache) {
        cacheSize += [[[fileManager attributesOfItemAtPath:url.path error:nil] valueForKey:NSFileSize] intValue];
    }
    
    NSLog(@"Cache Size = %d", cacheSize / 1000);
    
    if (cacheSize > MAXIMUM_SIZE) {
        URLsInCache = [URLsInCache sortedArrayUsingComparator:^(id item1, id item2) {
            NSDate* date1 = [[fileManager attributesOfItemAtPath:[item1 path] error:nil] valueForKey:NSFileModificationDate];
            NSDate* date2 = [[fileManager attributesOfItemAtPath:[item2 path] error:nil] valueForKey:NSFileModificationDate];
            
            return [date2 compare:date1];
            
        }];
        
        NSMutableArray* URLs = [NSMutableArray arrayWithArray:URLsInCache];
        
        while (cacheSize > MAXIMUM_SIZE/2 && URLs.count > 0) {
            NSURL* url = [URLs lastObject];
            
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:url.path error:nil];
            
            cacheSize -= [[fileAttributes valueForKey:NSFileSize] intValue];
            
            [URLs removeLastObject];
            
            if ([fileAttributes valueForKey:NSFileType] == NSFileTypeRegular) {
                [fileManager removeItemAtURL:url error:nil];
            }
        }
    }
}

+ (NSData*) get:(NSString *) key {

    return [NSData dataWithContentsOfURL:[ImageCache getUrl:key]];
}

+ (void)put:(NSString*) key withData:(NSData *)data {
    [data writeToURL:[ImageCache getUrl:key] atomically:YES];
    
    dispatch_queue_t cacheTrimQ = dispatch_queue_create("trimQ", NULL);
    dispatch_async(cacheTrimQ, ^{
        [[self class] trimeCache];
    });
    
    dispatch_release(cacheTrimQ);
    
}
@end
