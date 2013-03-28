//
//  BookmarksViewController.m
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 24.10.12.
//
//

#import "BookmarksViewController.h"

@implementation Bookmark

@synthesize name;
@synthesize offset;
@synthesize page;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init]) {
		self.name = [aDecoder decodeObjectForKey:@"NAME"];
		self.page = [(NSNumber *)[aDecoder decodeObjectForKey:@"PAGE"] intValue];
		float x = [(NSNumber *)[aDecoder decodeObjectForKey:@"X"] floatValue];
		float y = [(NSNumber *)[aDecoder decodeObjectForKey:@"Y"] floatValue];
		self.offset = CGPointMake(x, y);
	 }
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.name forKey:@"NAME"];
	[aCoder encodeObject:[NSNumber numberWithInt:self.page] forKey:@"PAGE"];
	[aCoder encodeObject:[NSNumber numberWithInt:self.offset.x] forKey:@"X"];
	[aCoder encodeObject:[NSNumber numberWithInt:self.offset.y] forKey:@"Y"];
}

- (id)init
{
	self = [super init];
	if (self) {
		self.name = NSLocalizedString(@"Новая закладка", nil);
		self.offset = CGPointMake(0, 0);
		self.page = 1;
	}
	return self;
}

- (id)initWithName:(NSString *)aName offset:(CGPoint)aOffset
{
	self = [super init];
	if (self) {
		self.name = aName;
		self.offset = aOffset;
		self.page = 1;
	}
	return self;
}

- (void)dealloc
{
	self.name = nil;
	self.page = 0;
	[super dealloc];
}

@end

@implementation BookmarksViewController

@synthesize delegate = m_delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.clearsSelectionOnViewWillAppear = NO;
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
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
	UIView *view = [[UIView alloc] initWithFrame:self.tableView.bounds];
	view.backgroundColor = backgroundColor;
	self.tableView.backgroundView = view;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self setNavigationBar];
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
	
    button.frame = CGRectMake(0, 0, 43, 26);
	
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
    return [m_delegate bookmarksCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	Bookmark *bookmark = [m_delegate bookmarkAtIndex:indexPath.row];
	cell.textLabel.text = bookmark.name;
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.textLabel.font = [UIFont fontWithName:@"StudioScriptCTT" size:25.0];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[m_delegate removeBookmarkWithIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (IS_IPAD) {
		[m_delegate openBookmark:indexPath.row];
		[tableView reloadData];
	} else {
		[m_delegate openBookmark:indexPath.row];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}


@end
