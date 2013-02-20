//
//  SubjectViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubjectViewController : UITableViewController {
	NSArray *m_keys;
}

@property (nonatomic, assign) int index;
@property (nonatomic, assign) NSDictionary *subjects;

@end
