//
//  ProceduralActionsViewController.h
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 22.10.12.
//
//

#import <UIKit/UIKit.h>
#import "PdfDelegate.h"

@interface PdfOptionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	id<PdfDelegate> m_delegate;
	NSArray *m_menuTitles;
    NSArray *m_menuSelectors;
	UITableView *m_tableView;
}

@property (nonatomic, assign) id<PdfDelegate> delegate;

@end
