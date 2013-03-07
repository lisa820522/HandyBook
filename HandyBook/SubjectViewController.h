//
//  ClassViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "IAPHelper.h"

@interface SubjectViewController : UITableViewController <NSXMLParserDelegate> {
	NSMutableDictionary *m_catalog;
	NSString *m_currentCategory;
	NSString *m_currentSubject;
	BOOL m_inParsing;
	UIView *m_lockView;
	UIActivityIndicatorView *m_activityView;
	NSArray *m_keys;
	BOOL m_isAlreadyUpdated;
}

@end
