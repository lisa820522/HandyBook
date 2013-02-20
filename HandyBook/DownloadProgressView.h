//
//  DownloadProgressView.h
//  BackgroundDownload
//
//  Created by Sergey Krupov on 12.09.12.
//  Copyright (c) 2012 Sergey Krupov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadProgressView : UIAlertView

- (id)initWithDelegate:(id<UIAlertViewDelegate>)delegate;

@property (nonatomic, assign) double downloadedSize;
@property (nonatomic, assign) double totalSize;

@end
