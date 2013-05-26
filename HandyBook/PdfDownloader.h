//
//  PdfDownloader.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PdfDownloaderDelegate <NSObject>

- (void)downloadingFailed;
- (void)didReceiveDataSize:(float)size;
- (void)didReceiveDataWithSize:(float)size;
- (void)didFinishedWithData:(NSData *)data;

@end

@interface PdfDownloader : NSObject <NSURLConnectionDataDelegate> {
	NSMutableData *m_currentData;
	NSURLConnection *m_connection;
	NSURLRequest *m_request;
	NSURL *m_url;
	id<PdfDownloaderDelegate> m_delegate;
}

@property (nonatomic, assign) id<PdfDownloaderDelegate> delegate;
@property (nonatomic, assign) float totalDataLength;
@property (nonatomic, assign) float currentDataLength;


+ (PdfDownloader *)sharedInstance;
- (void)downloadFile:(NSString *)fileName;
- (void)cancelDownloading;
- (void)freeMemory;

@end
