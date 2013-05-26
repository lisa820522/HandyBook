//
//  DownloadProgressView.h
//  BackgroundDownload
//
//  Created by Sergey Krupov on 12.09.12.
//  Copyright (c) 2012 Sergey Krupov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DownloadProgressViewDelegate <NSObject>

- (void)cancelDownload;

@end

@interface DownloadProgressView : UIView


@property (nonatomic, assign) id<DownloadProgressViewDelegate> delegate;
@property (nonatomic, assign) double downloadedSize;
@property (nonatomic, assign) double totalSize;

- (void)setTotalSize:(double)totalSize;
- (void)setDownloadedSize:(double)downloadedSize;
- (void)show;
- (void)hide;

@end
