//
//  StartViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 18.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface StartViewController : UIViewController {
	UIImageView *m_imageView;
	NSTimer *m_timer;
	MainViewController *m_mainVC;
}

@end
