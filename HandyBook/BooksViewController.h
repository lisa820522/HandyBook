//
//  BooksViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PdfDownloader.h"
#import "ImageCacheProvider.h"

#import "DownloadProgressView.h"

@interface BooksViewController : UITableViewController <UIAlertViewDelegate, PdfDownloaderDelegate, ImageCacheDelegate,
DownloadProgressViewDelegate> {
	
	DownloadProgressView *m_progressView;
	NSString *m_bookID;
	ImageCacheProvider *m_cacheProvider;
}

@property (nonatomic, retain) NSArray *books;
@property (nonatomic, retain) NSString *category;

@end
