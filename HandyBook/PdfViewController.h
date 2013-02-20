//
//  PdfViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PdfViewController : UIViewController <UIAlertViewDelegate, UIScrollViewDelegate, UIWebViewDelegate> {
	UIWebView *m_webView;
	UISlider *m_slider;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *fileName;

+ (PdfViewController *)sharedInstance;

@end
