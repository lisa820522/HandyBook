//
//  StartViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 18.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "StartViewController.h"
#import "ClassViewController.h"
#import "MainViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *imageName = @"startScreen";
	if (SCREENHEIGHT == IPADHEIGHT) {
		imageName = [imageName stringByAppendingString:@"-iPad"];
	} else if (SCREENHEIGHT == IPHONE5HEIGHT) {
		imageName = [imageName stringByAppendingString:@"-568h"];
	}
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	imageView.frame = self.view.bounds;
	[self.view addSubview:imageView];

	ClassViewController *classVC = [[ClassViewController alloc] initWithStyle:UITableViewStylePlain];
	m_mainVC = [[MainViewController alloc] initWithRootViewController:classVC];
	
	m_timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(push) userInfo:nil repeats:NO];
}

- (void)push
{
	[m_timer invalidate];
	[self presentModalViewController:m_mainVC animated:YES];
}

@end
