//
//  ClassViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface ClassViewController : UITableViewController <NSXMLParserDelegate, MFMailComposeViewControllerDelegate> {
	NSMutableDictionary *m_catalog;
	NSString *m_currentClassID;
	NSString *m_currentSubjectID;
	BOOL m_inParsing;
}

@end
