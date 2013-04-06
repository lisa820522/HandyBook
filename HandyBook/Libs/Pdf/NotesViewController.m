//
//  NotesViewController.m
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 06.11.12.
//
//

#import "NotesViewController.h"

@implementation Note

@synthesize text;
@synthesize offset;
@synthesize timestamp;
@synthesize page;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super init]) {
		self.text = [aDecoder decodeObjectForKey:@"TEXT"];
		self.page = [(NSNumber *)[aDecoder decodeObjectForKey:@"PAGE"] intValue];
		self.timestamp = [(NSNumber *)[aDecoder decodeObjectForKey:@"TIME"] longValue];
		float x = [(NSNumber *)[aDecoder decodeObjectForKey:@"X"] floatValue];
		float y = [(NSNumber *)[aDecoder decodeObjectForKey:@"Y"] floatValue];
		self.offset = CGPointMake(x, y);
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.text forKey:@"TEXT"];
	[aCoder encodeObject:[NSNumber numberWithInt:self.page] forKey:@"PAGE"];
	[aCoder encodeObject:[NSNumber numberWithLong:self.timestamp] forKey:@"TIME"];
	[aCoder encodeObject:[NSNumber numberWithInt:self.offset.x] forKey:@"X"];
	[aCoder encodeObject:[NSNumber numberWithInt:self.offset.y] forKey:@"Y"];
}

- (id)init
{
	self = [super init];
	if (self) {
		self.offset = CGPointMake(0, 0);
		self.page = 1;
	}
	return self;
}

- (id)initWithText:(NSString *)aText offset:(CGPoint)aOffset
{
	self = [self init];
	if (self) {
		self.offset = aOffset;
		self.text = aText;
	}
	return self;
}

- (void)dealloc
{
	self.text = nil;
	[super dealloc];
}

@end

@implementation NotesViewController

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
    return [m_delegate notesCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
	}
	
	Note *note = [m_delegate noteByIndex:indexPath.row];
	
	cell.textLabel.text = note.text;
	cell.textLabel.textColor = [UIColor blackColor];
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
        [m_delegate removeNoteWithIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (!IS_IPAD) {
		[self dismissViewControllerAnimated:YES completion:nil];
		[self performSelector:@selector(openNote:) withObject:[NSNumber numberWithInt:indexPath.row] afterDelay:0.5];
	}
}

- (void)openNote:(NSNumber *)number
{
	[m_delegate openNoteAtIndex:[number intValue]];
}

@end
