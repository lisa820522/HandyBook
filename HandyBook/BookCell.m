//
//  BookCell.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 18.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "BookCell.h"

@implementation BookCell

@synthesize book = m_book;
@synthesize thumbnailView = m_thumbnailView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        m_nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		m_nameLabel.backgroundColor = [UIColor clearColor];
		m_nameLabel.textColor = [UIColor blackColor];
		m_nameLabel.font = [UIFont fontWithName:@"StudioScriptCTT" size:25.0];
		
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		m_authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		m_authorLabel.backgroundColor = [UIColor clearColor];
		m_authorLabel.textColor = [UIColor grayColor];
		m_authorLabel.font = [UIFont fontWithName:@"StudioScriptCTT" size:20.0];
		
		m_thumbnailView = [[UIImageView alloc] init];
		[self addSubview:m_nameLabel];
		[self addSubview:m_authorLabel];
		[self addSubview:m_thumbnailView];
    }
    return self;
}

- (void)dealloc
{
	[m_nameLabel release];
	[m_authorLabel release];
	[m_thumbnailView release];
	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	m_thumbnailView.frame = CGRectMake(5, 5, 52.5, self.frame.size.height - 10);
	m_nameLabel.frame = CGRectMake(63, 10, self.frame.size.width - 86, (self.frame.size.height - 20) / 2);
	m_authorLabel.frame = CGRectMake(63, m_nameLabel.frame.origin.y + m_nameLabel.frame.size.height + 10,
									 self.frame.size.width - 86, (self.frame.size.height - 25) / 2);
}

- (void)setBook:(NSDictionary *)book
{
	m_book = book;
	m_nameLabel.text = [book objectForKey:@"name"];
	m_authorLabel.text = [[book objectForKey:@"author"] stringByAppendingFormat:@", %@", [book objectForKey:@"info"]];
//	UIImage *img = [UIImage imageNamed:[[book objectForKey:@"file"] stringByAppendingString:@".jpg"]];
//	m_thumbnailView.image = img;
}

@end
