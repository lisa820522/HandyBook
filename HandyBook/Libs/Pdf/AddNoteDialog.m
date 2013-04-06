//
//  AddNoteDialog.m
//  ExpressAnalysis
//
//  Created by Sema Belokovsky on 06.11.12.
//
//

#import "AddNoteDialog.h"
#import <QuartzCore/QuartzCore.h>

@implementation AddNoteDialog

@synthesize delegate = m_delegate;
@synthesize timestamp = m_timestamp;
@synthesize mode;
@synthesize noteIndex;

- (id)init
{
	self = [super init];
	if (self) {
		self.mode = kNoteDialogNewNote;
		self.noteIndex = 0;
		self.point = CGPointMake(0, 0);
		[self.view.layer setCornerRadius:5];
		NSDate *date = [NSDate date];
		m_timestamp = [date timeIntervalSince1970];
	}
	return self;
}

- (void)loadView
{
	[super loadView];
	self.view.backgroundColor = [UIColor blackColor];
	
	m_textView = [[UITextView alloc] initWithFrame:CGRectZero];
	m_textView.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
	m_textView.textColor = [UIColor blackColor];
	[self.view addSubview:m_textView];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Отмена", nil)
															   style:UIBarButtonItemStyleDone
															  target:self
															  action:@selector(cancelAction:)] autorelease];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Сохранить", nil)
											  style:UIBarButtonItemStyleDone
											 target:self
											 action:@selector(saveAction:)] autorelease];
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
	m_textView.backgroundColor = backgroundColor;
	
	[self setNavigationBar];
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refresh];
}

- (void)cancelAction:(id)sender
{
	[m_delegate cancelNote];
	if (!IS_IPAD) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)refresh
{
	NSDate *date = [NSDate dateWithTimeIntervalSince1970:m_timestamp];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"HH:mm:ss"];
	self.navigationItem.title = [dateFormat stringFromDate:date];
	[dateFormat release];
	
	m_textView.text = self.text;
	m_textView.frame = self.view.bounds;
}

- (void)reset
{
	NSDate *date = [NSDate date];
	m_timestamp = [date timeIntervalSince1970];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"HH:mm:ss"];
	self.navigationItem.title = [dateFormat stringFromDate:date];
	[dateFormat release];
	
	self.text = @"";
	m_textView.text = self.text;
	m_textView.frame = self.view.bounds;
}

- (void)saveAction:(id)sender
{
	if (self.mode == kNoteDialogNewNote) {
		[m_delegate addNote:self.point withText:m_textView.text timestamp:m_timestamp];
	} else {
		[m_delegate editNoteAtIndex:self.noteIndex point:self.point text:m_textView.text timestamp:m_timestamp];
	}
	if (!IS_IPAD) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
