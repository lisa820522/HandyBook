//
//  StoreViewController.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GDZIAPHelper.h"

@interface StoreViewController : UIViewController <NSXMLParserDelegate> {
	UILabel *m_bookLabel;
	UILabel *m_infoLabel;
	UILabel *m_complectLabel;
	UILabel *m_bookPrice;
	UILabel *m_complectPrice;
	UILabel *m_allPrice;
	NSNumberFormatter *m_priceFormatter;
	NSArray  *m_products;
	UIActivityIndicatorView *m_activityView;
}

@property (nonatomic, retain) NSString *bookID;
@property (nonatomic, retain) NSString *bookName;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) NSString *complect;

+ (StoreViewController *)sharedInstance;

@end
