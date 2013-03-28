//
//  ProceduralActionsViewController.m
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 22.10.12.
//
//

#import "PdfOptionsViewController.h"
#import "NotesViewController.h"
#import "BookmarksViewController.h"

@implementation PdfOptionsViewController

@synthesize delegate = m_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = NSLocalizedString(@"Действия", nil);
    }
    return self;
}

- (void)loadView
{
    [super loadView];
	m_menuTitles = [[NSArray arrayWithObjects:
					 NSLocalizedString(@"Закладки", nil),
					 NSLocalizedString(@"Заметки", nil),
					 nil] retain];
	
	m_menuSelectors = [[NSArray arrayWithObjects:
						[NSValue valueWithPointer:@selector(goBookmarks)],
						[NSValue valueWithPointer:@selector(goNotes)],
						nil] retain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSString *imageName = @"blackboard";
	if (IS_IPAD) {
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
	self.view.backgroundColor = backgroundColor;
	
	m_tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	m_tableView.dataSource = self;
	m_tableView.delegate = self;
	m_tableView.backgroundColor = [UIColor clearColor];
	m_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self.view addSubview:m_tableView];
	
	if (!IS_IPAD) {
		[self setNavigationBar];
	}
	
	imageName = @"navBar";
	if (IS_IPAD) {
		imageName = [imageName stringByAppendingString:@"-iPad"];
	}
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
	UIImage *image = [UIImage imageNamed:imageName];
	image = [UIImage imageWithCGImage:[image CGImage] scale:2 orientation:UIImageOrientationUp];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[imageView setFrame:CGRectMake(0,
								   self.view.frame.size.height - 44 - self.navigationController.navigationBar.frame.size.height,
								   self.view.frame.size.width,
								   44)];
	[self.view addSubview:imageView];
	[imageView release];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0,
							  self.view.frame.size.height - 44 - self.navigationController.navigationBar.frame.size.height,
							  self.view.frame.size.width,
							  44);
	[button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *buttonLabel = [[UILabel alloc] initWithFrame:button.bounds];
	buttonLabel.backgroundColor = [UIColor clearColor];
	buttonLabel.textAlignment = UITextAlignmentCenter;
	buttonLabel.textColor = [UIColor whiteColor];
	buttonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
	buttonLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    buttonLabel.shadowOffset = CGSizeMake(0, -1.0);
	buttonLabel.text = @"Отмена";
	
	[button addSubview:buttonLabel];
	[buttonLabel release];
	
	[self.view addSubview:button];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	if (IS_IPAD) {
		self.contentSizeForViewInPopover = CGSizeMake(300.0, 201.0);
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	if (IS_IPAD) {
		self.contentSizeForViewInPopover = CGSizeMake(300.0, 200.0);
	}
}

- (void)setNavigationBar
{
	NSString *imageName = @"navBar";
	if (IS_IPAD) {
		imageName = [imageName stringByAppendingString:@"-iPad"];
	}
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
	UIImage *image = [UIImage imageNamed:imageName];
	image = [UIImage imageWithCGImage:[image CGImage] scale:2 orientation:UIImageOrientationUp];
	[self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
}

- (void)cancel
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [m_menuTitles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}

	cell.textLabel.text = [m_menuTitles objectAtIndex:indexPath.section];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.font = [UIFont fontWithName:@"StudioScriptCTT" size:25.0];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    SEL selector = [[m_menuSelectors objectAtIndex:indexPath.section] pointerValue];
    [self performSelector:selector];
}

- (void)goNotes
{
	NotesViewController *ctl = [[NotesViewController alloc] initWithStyle:UITableViewStylePlain];
	ctl.delegate = m_delegate;
	ctl.title = @"Заметки";
	if (IS_IPAD) {
		ctl.contentSizeForViewInPopover = CGSizeMake(300, 600);
	}
	[self.navigationController pushViewController:ctl animated:YES];
	[ctl release];
}

- (void)goBookmarks
{
	BookmarksViewController *ctl = [[BookmarksViewController alloc] initWithStyle:UITableViewStylePlain];
	ctl.delegate = m_delegate;
	ctl.title = @"Закладки";
	if (IS_IPAD) {
		ctl.contentSizeForViewInPopover = CGSizeMake(300, 600);
	}
	[self.navigationController pushViewController:ctl animated:YES];
	[ctl release];
}


@end
