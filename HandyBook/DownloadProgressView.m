//
//  DownloadProgressView.m
//  BackgroundDownload
//
//  Created by Sergey Krupov on 12.09.12.
//  Copyright (c) 2012 Sergey Krupov. All rights reserved.
//

#import "DownloadProgressView.h"

@interface DownloadProgressView ()
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) UIImageView *imageView;
@end

@implementation DownloadProgressView {
    UIActivityIndicatorView *m_activityView;
    CGFloat m_deltaHeight;
    CGFloat m_bottomMargin;
    CGFloat m_topMargin;
    CGRect m_fakeFrame;
}

@synthesize button = m_button;
@synthesize imageView = m_imageView;
@synthesize downloadedSize = m_downloadedSize;
@synthesize totalSize = m_totalSize;

- (id)initWithDelegate:(id<UIAlertViewDelegate>)delegate
{
    NSString *title = @"Скачивание";
    
	NSString *message = [self __messageForDoneBytes:0 totalBytes:0];
	
    self = [super initWithTitle:title
                        message:message
                       delegate:delegate
              cancelButtonTitle:@"Отмена"
              otherButtonTitles:nil];
	
    if (self != nil) {
        m_totalSize = 0;
        m_downloadedSize = 0;
        m_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
    }
    return self;
}

- (void)dealloc
{
    [m_activityView release];
    [m_imageView release];
    [m_button release];
    [super dealloc];
}

- (void)show
{
    [super show];
    
    // Look for controls, don't rely on private methods
    CGFloat maxY = 0;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:UIImageView.class]) {
            self.imageView = (UIImageView*) view;
        }
        else if ([view isKindOfClass:UIButton.class]) {
            self.button = (UIButton *) view;
        }
        else if ([view isKindOfClass:UILabel.class]) {
            CGFloat y = CGRectGetMaxY(view.frame);
            maxY = MAX(y, maxY);
        }
    }
    
    CGRect selfFrame = [super frame];
    CGRect imageViewFrame = self.imageView.frame;
    CGRect activityViewFrame = m_activityView.frame;
    CGRect buttonFrame = self.button.frame;
    
    m_bottomMargin = CGRectGetMaxY(imageViewFrame) - CGRectGetMaxY(buttonFrame);
    m_topMargin = CGRectGetMinY(buttonFrame) - maxY;
    m_deltaHeight = (CGRectGetHeight(selfFrame) / CGRectGetHeight(imageViewFrame) * CGRectGetHeight(activityViewFrame)) + m_topMargin;
    
    selfFrame.origin.y    -= m_deltaHeight / 2;
    selfFrame.size.height += m_deltaHeight;
    [super setFrame:CGRectIntegral(selfFrame)];
    [self setNeedsLayout];
    
    [self addSubview:m_activityView];
    [m_activityView startAnimating];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.button == nil || self.imageView == nil) return;
    
    CGRect buttonFrame = self.button.frame;
    CGRect imageViewFrame = self.imageView.frame;
    CGRect activityViewFrame = m_activityView.frame;
    
    buttonFrame.origin.y = CGRectGetHeight(imageViewFrame) - m_bottomMargin - CGRectGetHeight(buttonFrame);
    self.button.frame = CGRectIntegral(buttonFrame);
    
    activityViewFrame.origin.x = roundf((CGRectGetWidth(imageViewFrame) - CGRectGetWidth(activityViewFrame)) / 2);
    activityViewFrame.origin.y = roundf(CGRectGetMinY(buttonFrame) - CGRectGetHeight(activityViewFrame) - m_topMargin);
    m_activityView.frame = CGRectIntegral(activityViewFrame);
}

- (NSString *)__messageForDoneBytes:(double)doneBytes totalBytes:(double)totalBytes
{
    NSString *beginingOfMessage = nil;

	beginingOfMessage = @"Загружено";
	
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


- (CGRect)frame
{
    return m_fakeFrame;
}

- (void)setFrame:(CGRect)frame
{
    m_fakeFrame = frame;
    
    frame.origin.y    -= m_deltaHeight / 2;
    frame.size.height += m_deltaHeight;
    [super setFrame:CGRectIntegral(frame)];
}

#pragma mark - properties

- (void)setDownloadedSize:(double)downloadedSize
{
    if (m_downloadedSize == downloadedSize) return;
    m_downloadedSize = downloadedSize;
    self.message = [self __messageForDoneBytes:m_downloadedSize totalBytes:m_totalSize];
}

- (void)setTotalSize:(double)totalSize
{
    if (m_totalSize == totalSize) return;
    m_totalSize = totalSize;
    self.message = self.message = [self __messageForDoneBytes:m_downloadedSize totalBytes:m_totalSize];
}

@end
