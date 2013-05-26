//
//  PdfDownloader.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "PdfDownloader.h"

@implementation PdfDownloader

@synthesize delegate = m_delegate;

static PdfDownloader *m_sharedInstance = nil;

+ (PdfDownloader *)sharedInstance
{
    @synchronized(self)
    {
        if (m_sharedInstance == nil)
        {
			m_sharedInstance = [NSAllocateObject([self class], 0, NULL) init];
        }
    }
	
    return m_sharedInstance;
}

- (void)dealloc
{
	if (m_currentData) {
		[m_currentData release];
	}
	[super dealloc];
}

- (void)freeMemory
{
	[m_currentData release];
	m_currentData = nil;
}

- (void)downloadFile:(NSString *)fileName
{
	if (m_currentData) {
		[m_currentData release];
		m_currentData = nil;
	}
	if (m_url) {
		[m_url release];
		m_url = nil;
	}
	if (m_request) {
		[m_request release];
		m_request = nil;
	}
	NSString *urlString =  [SERVERURL stringByAppendingString:fileName];
	
	DLog(@"%@", urlString);
	
	m_url = [[NSURL alloc] initWithString:urlString];
	m_request = [[NSURLRequest alloc] initWithURL:m_url];
	m_connection = [[NSURLConnection alloc] initWithRequest:m_request delegate:self startImmediately:YES];
	CFRunLoopRun();
	if (m_connection == nil) {
		[m_delegate downloadingFailed];
	}
}

- (void)cancelDownloading
{
	[m_connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	DLog(@"%ll", response.expectedContentLength);
	if ([response.MIMEType isEqualToString:@"application/pdf"]) {
		m_currentData = [[NSMutableData alloc] init];
		self.totalDataLength = response.expectedContentLength;
		[m_delegate didReceiveDataSize:self.totalDataLength];
	} else {
		[m_delegate downloadingFailed];
		[connection cancel];
		CFRunLoopStop(CFRunLoopGetCurrent());
	}
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_currentData appendData:data];
	float size = [data length];
	[m_delegate didReceiveDataWithSize:size];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[m_delegate didFinishedWithData:(NSData *)m_currentData];
	CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[m_delegate downloadingFailed];
	CFRunLoopStop(CFRunLoopGetCurrent());
}

@end
