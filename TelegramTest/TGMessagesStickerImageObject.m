//
//  TGMessagesStickerImageObject.m
//  Telegram
//
//  Created by keepcoder on 19.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGMessagesStickerImageObject.h"
#import "DownloadPhotoItem.h"
@implementation TGMessagesStickerImageObject


-(void)initDownloadItem {
    
    
    if(self.downloadItem )
        return;//[self.downloadItem cancel];
    
    
    self.downloadItem = [[DownloadPhotoItem alloc] initWithObject:self.location size:self.size];
    
    self.downloadListener = [[DownloadEventListener alloc] initWithItem:self.downloadItem];
    
    [self.downloadItem addEvent:self.downloadListener];
    
    
    weak();
    
    [self.downloadListener setCompleteHandler:^(DownloadItem * item) {
        [weakSelf _didDownloadImage:item];
        weakSelf.downloadItem = nil;
        weakSelf.downloadListener = nil;
    }];
    
    
    [self.downloadListener setProgressHandler:^(DownloadItem * item) {
        if([weakSelf.delegate respondsToSelector:@selector(didUpdatedProgress:)]) {
            [weakSelf.delegate didUpdatedProgress:item.progress];
        }
    }];
    
    
    [self.downloadItem start];
}

-(void)_didDownloadImage:(DownloadItem *)item {
    NSImage *image = [[NSImage alloc] initWithData:item.result];
    
    if(!image)
        image = [NSImage imageWithWebpData:item.result error:nil];
    
    if(image != nil) {
        
        image = renderedImage(image, self.imageSize);
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    }
    
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

-(void)dealloc {
    [self.downloadItem removeEvent:self.downloadListener];
    self.downloadItem = nil;
}

-(NSString *)cacheKey {
    return self.location.cacheKey;
}

@end
