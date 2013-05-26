//
//  DownloadProgressView.m
//  BackgroundDownload
//
//  Created by Sergey Krupov on 12.09.12.
//  Copyright (c) 2012 Sergey Krupov. All rights reserved.
//

#import "DownloadProgressView.h"

@implementation DownloadProgressView {
    UIActivityIndicatorView *m_activityView;
	UILabel *m_header;
	UILabel *m_message;
	UIButton *m_button;
}

@synthesize delegate;

@synthesize downloadedSize = m_downloadedSize;
@synthesize totalSize = m_totalSize;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		
		m_header = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 280, 24)];
		m_header.backgroundColor = [UIColor clearColor];
		m_header.textAlignment = NSTextAlignmentCenter;
		m_header.text = @"Загрузка";
		m_header.textColor = [UIColor whiteColor];
		[self addSubview:m_header];
		
		m_message = [[UILabel alloc] initWithFrame:CGRectMake(0, 34, 280, 24)];
		m_message.backgroundColor = [UIColor clearColor];
		m_message.textAlignment = NSTextAlignmentCenter;
		m_message.text = [self __messageForDoneBytes:0 totalBytes:0];
		m_message.textColor = [UIColor whiteColor];
		[self addSubview:m_message];
		
		m_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		m_activityView.frame = CGRectMake((self.frame.size.width - 50)/2, (self.frame.size.height - 50)/2, 50, 50);
		[self addSubview:m_activityView];
		
		m_button = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 150)/2, (self.frame.size.height - 50)/2 + 50, 150, 45)];
		[m_button setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
		[m_button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:m_button];
	}
	return self;
}

- (void)show
{
	self.frame = CGRectMake((self.superview.frame.size.width - 280)/2, (self.superview.frame.size.height - 200)/2, 280, 200);
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	self.alpha = 1;
	[UIView commitAnimations];
	[m_activityView startAnimating];
}

- (void)hide
{
	m_totalSize = 0;
	m_downloadedSize = 0;
	m_message.text = [self __messageForDoneBytes:0 totalBytes:0];
	[m_activityView stopAnimating];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	self.alpha = 0;
	[UIView commitAnimations];
}

- (void)cancel
{
	[self.delegate cancelDownload];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	m_activityView.frame = CGRectMake((self.frame.size.width - 50)/2, (self.frame.size.height - 50)/2, 50, 50);
	m_button.frame = CGRectMake((self.frame.size.width - 150)/2, (self.frame.size.height - 50)/2 + 50, 150, 45);
	m_header.frame = CGRectMake(0, 5, 280, 24);
	m_message.frame = CGRectMake(0, 34, 280, 24);
}

- (NSString *)__messageForDoneBytes:(double)doneBytes totalBytes:(double)totalBytes
{
    NSString *beginingOfMessage = nil;

	beginingOfMessage = NSLocalizedString(@"Загружено", nil);
	
    if (m_totalSize == 0) {
        return beginingOfMessage;
    }
    
    NSMutableString *message = [NSMutableString stringWithCapacity:128];
    [message appendFormat:@"%@: ", beginingOfMessage];
    if (totalBytes < 1024 * 1024) {
        [message appendFormat:@"%0.1f KB", (doneBytes / 1024)];
    } else {
        [message appendFormat:@"%0.1f MB", (doneBytes / 1024 / 1024)];
    }
    int percent = round(doneBytes / totalBytes * 100);
    [message appendFormat:@" (%d%%)", percent];
    return message;
}

#pragma mark - properties

- (void)setDownloadedSize:(double)downloadedSize
{
    if (m_downloadedSize == downloadedSize) return;
    m_downloadedSize = downloadedSize;
    m_message.text = [self __messageForDoneBytes:m_downloadedSize totalBytes:m_totalSize];
}

- (void)setTotalSize:(double)totalSize
{
    if (m_totalSize == totalSize) return;
    m_totalSize = totalSize;
    m_message.text = [self __messageForDoneBytes:m_downloadedSize totalBytes:m_totalSize];
}

@end
