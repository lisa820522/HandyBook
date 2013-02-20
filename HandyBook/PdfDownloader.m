//
//  PdfDownloader.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "PdfDownloader.h"

@implementation PdfDownloader

@synthesize delegate;

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
	NSString *urlString = [SERVERURL stringByAppendingString:fileName];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	m_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if (m_connection == nil) {
		[self.delegate downloadingFailed];
	}
}

- (void)cancelDownloading
{
	[m_connection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if (m_currentData) {
		[m_currentData release];
	}
	m_currentData = [[NSMutableData alloc] init];
	self.totalDataLength = response.expectedContentLength;
	[self.delegate didReceiveDataSize:self.totalDataLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[m_currentData appendData:data];
	[self.delegate didReceiveDataWithSize:[data length]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self.delegate didFinishedWithData:(NSData *)m_currentData];
}

@end
