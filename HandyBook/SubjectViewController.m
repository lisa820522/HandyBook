//
//  SubjectViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "SubjectViewController.h"

#import "MainViewController.h"
#import "NameHelper.h"
#import "BooksViewController.h"

@implementation SubjectViewController

@synthesize index;
@synthesize subjects;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	[m_keys release];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *imageName = @"blackboard";
	if (SCREENHEIGHT == IPADHEIGHT) {
		imageName = [imageName stringByAppendingString:@"-iPad"];
	} else if (SCREENHEIGHT == IPHONE5HEIGHT) {
		imageName = [imageName stringByAppendingString:@"-568h"];
	}
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
	UIColor *backgroundColor;
	backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:imageName]];
	UIView *view = [[UIView alloc] initWithFrame:self.tableView.bounds];
	view.backgroundColor = backgroundColor;
	self.tableView.backgroundView = view;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self setNavigationBar];
	
	m_keys = [[[self.subjects allKeys] sortedArrayUsingSelector:@selector(compare:)] retain];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	((MainViewController *)self.navigationController).titleLabel.text = [NSString stringWithFormat:@"%d класс", self.index];
}

- (void)setNavigationBar
{
	NSString *imageName = @"buttonBack";
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
	
	imageName = @"buttonBackDown";
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    button.adjustsImageWhenDisabled = NO;
	
    button.frame = CGRectMake(0, 7, 35, 30);
	
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
	
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = customBarItem;
    self.navigationItem.hidesBackButton = YES;
	
    [customBarItem release];
}

- (void)back
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_keys count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	cell.textLabel.text = [@"• " stringByAppendingString:[NameHelper nameForSubjectWithIndex:[[m_keys objectAtIndex:[indexPath row]] intValue]]];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.font = [UIFont fontWithName:@"StudioScriptCTT" size:25.0];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BooksViewController *ctl = [[BooksViewController alloc] initWithStyle:UITableViewStylePlain];
	ctl.books = [self.subjects objectForKey:[m_keys objectAtIndex:[indexPath row]]];
	ctl.index = [[m_keys objectAtIndex:[indexPath row]] intValue];
	[self.navigationController pushViewController:ctl animated:YES];
	[ctl release];
}

@end
