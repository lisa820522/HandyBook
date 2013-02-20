//
//  BookCell.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 18.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCell : UITableViewCell {
	UILabel *m_nameLabel;
	UILabel *m_authorLabel;
	UIImageView *m_thumbnailView;
	NSDictionary *m_book;
}

@property (nonatomic, retain) NSDictionary *book;

@end
