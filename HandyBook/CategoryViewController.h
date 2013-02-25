//
//  SubjectViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryViewController : UITableViewController {
	NSArray *m_keys;
	NSDictionary *m_categories;
}

@property (nonatomic, retain) NSDictionary *categories;

@end
