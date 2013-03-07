//
//  MainViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

@synthesize titleLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *imageName = @"navBar";
	if (SCREENHEIGHT == 1024) {
		imageName = [imageName stringByAppendingString:@"-iPad"];
	}
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
	UIImage *image = [UIImage imageNamed:imageName];
	if (ISRETINA) {
		image = [UIImage imageWithCGImage:[image CGImage] scale:2 orientation:UIImageOrientationUp];
	}
	[self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 200)/ 2, 0, 200, 44)];
	self.titleLabel.backgroundColor = [UIColor clearColor];
	self.titleLabel.textAlignment = UITextAlignmentCenter;
	self.titleLabel.textColor = [UIColor whiteColor];
	self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
	self.titleLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.titleLabel.shadowOffset = CGSizeMake(0, -1.0);
	[self.navigationBar addSubview:self.titleLabel];
}

@end
