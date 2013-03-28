//
//  PdfViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "PdfViewController.h"
#import "MainViewController.h"
#import "PdfDelegate.h"
#import "BookmarksViewController.h"
#import "NotesViewController.h"
#import "AddNoteDialog.h"

@interface TransparentToolbar : UIToolbar

@end

@implementation TransparentToolbar

- (void)drawRect:(CGRect)rect
{
	
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    double width = 10.0;
    for (UIView *view in self.subviews) {
        width += view.frame.size.width + 20;
    }
    
    size.width = width;
    
    return size;
}

@end

@interface Document : NSObject

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSMutableArray *bookmarks;
@property (nonatomic, retain) NSMutableArray *notes;

@end

@implementation Document

@synthesize path;
@synthesize bookmarks;
@synthesize notes;

- (id)init
{
	self = [super init];
	if (self) {
		self.bookmarks = [[NSMutableArray alloc] init];
		self.notes = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	self.bookmarks = nil;
	self.notes = nil;
	[super dealloc];
}

@end

@implementation PdfViewController

@synthesize name;
@synthesize fileName;

static PdfViewController *m_sharedInstance = nil;

+ (PdfViewController *)sharedInstance
{
    @synchronized(self)
    {
        if (m_sharedInstance == nil)
        {
			m_sharedInstance = [NSAllocateObject([self class], 0, NULL) initWithNibName:nil bundle:nil];
        }
    }
	
    return m_sharedInstance;
}

- (void)dealloc
{
	[m_pdfView release];
	[super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
	
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:imageName]];
	
	[self setNavigationBar];
	m_notesViews = [[NSMutableArray alloc] init];
}

- (void)loadPdfView
{
	if (!m_pdfView) {
		m_pdfView = [[PdfView alloc] initWithFrame:CGRectZero];
		UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)] autorelease];
		tapRecognizer.numberOfTapsRequired = 1;
		UITapGestureRecognizer *doubleTapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:nil] autorelease];
		doubleTapRecognizer.numberOfTapsRequired = 2;
		[tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
		[m_pdfView addGestureRecognizer:tapRecognizer];
		[m_pdfView addGestureRecognizer:doubleTapRecognizer];
		m_pdfView.delegate = self;
	}
	
	m_currentPage = 1;
	
	[m_pdfView setDocument:m_currentDocumentRef];
	if (!m_pdfView.superview) {
		[self.view addSubview:m_pdfView];
	}
	
	if (!m_slider) {
		m_slider = [[UISlider alloc] initWithFrame:CGRectMake(20,
															  self.view.frame.size.height - 100 - self.navigationController.navigationBar.frame.size.height,
															  self.view.frame.size.width - 40,
															  20)];
		m_slider.minimumValue = 0;
		m_slider.maximumValue = 100;
		m_slider.value = 0;
		m_slider.hidden = YES;
		[m_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	}
	
	if (!m_slider.superview) {
		[self.view addSubview:m_slider];
	}
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	((MainViewController *)self.navigationController).titleLabel.text = @"";
	
	[self setupBar];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	m_lastShownPopoveryType = kActionPopoverNone;
}

- (void)reloadDocument
{
	[m_document release];
	m_document = nil;
	
	CGPDFDocumentRelease(m_currentDocumentRef);
	
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
	if (fileExists) {
		NSURL *url = [NSURL fileURLWithPath:fullPath];
		m_currentDocumentRef = CGPDFDocumentCreateWithURL((CFURLRef)url);
		
		m_document = [[Document alloc] init];
		
		m_document.path = [url absoluteString];
	} else {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Ощибка" message:@"Извините, произошла ошибка чтения файла" delegate:self cancelButtonTitle:@"ОК" otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
		return;
	}
	
	[self loadDocument];
	
	for (UIView *i in m_notesViews) {
		[i removeFromSuperview];
	}
	[m_notesViews removeAllObjects];
	
	if ([m_pdfView superview]) {
		[m_pdfView removeFromSuperview];
	}
	if ([m_slider superview]) {
		[m_slider removeFromSuperview];
	}
	
	[m_pdfView release];
	m_pdfView = nil;
	
	[m_slider release];
	m_slider = nil;
	
	[self loadPdfView];
	
	[m_pdfView setFrame:self.view.bounds];
	[m_pdfView layoutSubviews];
	[m_pdfView setNeedsDisplay];
	
	int pagesCount = CGPDFDocumentGetNumberOfPages(m_currentDocumentRef);
	float pxPP = m_pdfView.contentSize.height / pagesCount;
	
	m_bookmarkButtonItem.image = [UIImage imageNamed:@"bookmarkUnselected.png"];
	NSMutableArray *bookmarks = [m_document bookmarks];
	for (Bookmark *i in bookmarks) {
		if (fabs(i.offset.y - m_pdfView.contentOffset.y) <= pxPP) {
			m_bookmarkButtonItem.image = [UIImage imageNamed:@"bookmarkSelected.png"];
		}
	}
	
	for (Note *note in m_document.notes) {
		UIButton *noteView = [UIButton buttonWithType:UIButtonTypeCustom];
		[noteView setImage:[UIImage imageNamed:@"note.png"] forState:UIControlStateNormal];
		[noteView addTarget:self action:@selector(editNoteAction:) forControlEvents:UIControlEventTouchUpInside];
		noteView.tag = [m_notesViews count];
		[m_notesViews addObject:noteView];
		float scale = m_pdfView.zoomScale;
		noteView.frame = CGRectMake(note.offset.x*scale-12, note.offset.y*scale-12, 24, 24);
		[m_pdfView addSubview:noteView];
	}
	
	[m_pdfView setFrame:self.view.bounds];
	[m_pdfView layoutSubviews];
	[m_pdfView setNeedsDisplay];
}

- (void)saveDocument
{
	NSMutableData *data = [[NSMutableData new] autorelease];
    NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
	NSString *key;
	key = [@"notes" stringByAppendingFormat:@".%@", self.fileName];
	[archiver encodeObject:m_document.notes forKey:key];
	key = [@"bookmarks" stringByAppendingFormat:@".%@", self.fileName];
	[archiver encodeObject:m_document.bookmarks forKey:key];
	[archiver finishEncoding];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:[@"document" stringByAppendingFormat:@".%@", self.fileName]];
}

- (void)loadDocument
{
	NSData *data = [[NSUserDefaults standardUserDefaults]
					objectForKey:[@"document" stringByAppendingFormat:@".%@", self.fileName]];
	NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
	NSString *key = key = [@"notes" stringByAppendingFormat:@".%@", self.fileName];
	NSArray *array = [unarchiver decodeObjectForKey:key];
	[m_document.notes addObjectsFromArray:array];
	
	key = key = [@"bookmarks" stringByAppendingFormat:@".%@", self.fileName];
	array = [unarchiver decodeObjectForKey:key];
	[m_document.bookmarks addObjectsFromArray:array];
}

- (void)setupBar
{
	[self updateRightBarItem];
	if (!m_rightBarButtonItem.superview) {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:m_rightBarButtonItem] autorelease];
	}
}

- (void)updateRightBarItem
{
	if (!m_rightBarButtonItem) {
		m_rightBarButtonItem = [self createRightBarItem];
	}
}

- (UIToolbar *)createRightBarItem
{
    UIToolbar *result = [[[TransparentToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 44)] autorelease];
	result.translucent = YES;
    result.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    result.backgroundColor = [UIColor clearColor];
    
	
	
    NSMutableArray *buttons = [NSMutableArray new];
	
	UIBarButtonItem *button;
	UIBarButtonItem *space;
	
	button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addNote.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addNoteAction:)];
	[buttons addObject:button];
	[button release];
	
	space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:space];
	[space release];
	
	m_bookmarkButtonItem = button = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmarkUnselected.png"] style:UIBarButtonItemStylePlain target:self action:@selector(toggleBookmarkAction:)] autorelease];
	[buttons addObject:button];
	
	
	space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:space];
	[space release];
	
	button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(optionsAction:)];
	[buttons addObject:button];
	[button release];
	
	space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[buttons addObject:space];
	[space release];
	
    [result setItems:buttons];
    [buttons release];
    
    CGSize bestSize = [result sizeThatFits:result.frame.size];
    CGRect frame = result.frame;
    frame.size = bestSize;
    
    result.frame = frame;
    
    return result;
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
	[self hidePageLabel];
	if (IS_IPAD) {
		[m_popoverController dismissPopoverAnimated:NO];
		[m_popoverController release];
		m_popoverController = nil;
	}
	m_lastShownPopoveryType = kActionPopoverNone;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)sliderValueChanged:(id)sender
{
	[m_pdfView setZoomScale:1];
	CGPoint offset = CGPointMake(0, (m_pdfView.contentSize.height - self.view.frame.size.height) * m_slider.value / 100);
	[m_pdfView setContentOffset:offset animated:NO];
}

- (void)addNoteAction:(id)sender
{
	[self hidePageLabel];
	
	m_mode = kNoteMode;
}

- (void)optionsAction:(id)sender
{
	[self hidePageLabel];
	
	if (IS_IPAD) {
        if (m_popoverController) {
            [m_popoverController dismissPopoverAnimated:YES];
            [m_popoverController release];
            m_popoverController = nil;
        }
        if (m_lastShownPopoveryType != kActionPopoverOptions) {
            m_lastShownPopoveryType = kActionPopoverOptions;
			PdfOptionsViewController *ctl = [[[PdfOptionsViewController alloc] initWithNibName:nil bundle:nil] autorelease];
			ctl.contentSizeForViewInPopover = CGSizeMake(300.0, 200.0);
			ctl.delegate = self;
            UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
            m_popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
            m_popoverController.delegate = self;
            [m_popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else {
            m_lastShownPopoveryType = kActionPopoverNone;
        }
    } else {
		if (m_lastShownPopoveryType != kActionPopoverOptions) {
            m_lastShownPopoveryType = kActionPopoverOptions;
			PdfOptionsViewController *ctl = [[[PdfOptionsViewController alloc] initWithNibName:nil bundle:nil] autorelease];
			ctl.delegate = self;
			UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
			[self presentViewController:navController animated:YES completion:nil];
        }
        else {
            m_lastShownPopoveryType = kActionPopoverNone;
        }
	}
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)toggleBookmarkAction:(id)sender
{
	[self hidePageLabel];
	
	NSMutableArray *bookmarks = [m_document bookmarks];
	int pagesCount = CGPDFDocumentGetNumberOfPages(m_currentDocumentRef);
	float pxPP = m_pdfView.contentSize.height / pagesCount;
	for (Bookmark *i in bookmarks) {
		if (fabs(i.offset.y - m_pdfView.contentOffset.y) <= pxPP) {
			[bookmarks removeObject:i];
			m_bookmarkButtonItem.image = [UIImage imageNamed:@"bookmarkUnselected.png"];
			return;
		}
	}
	NSString *bookmarkName = @"Страница";
	bookmarkName = [bookmarkName stringByAppendingFormat:@" %d",m_currentPage];
	
	Bookmark *bookmark = [[Bookmark alloc] initWithName:bookmarkName offset:[m_pdfView contentOffset]];
	bookmark.page = m_currentPage;
	[bookmarks addObject:bookmark];
	m_bookmarkButtonItem.image = [UIImage imageNamed:@"bookmarkSelected.png"];
	
	[self saveDocument];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if (m_lastShownPopoveryType != kActionPopoverSearch) {
		m_mode = kReadMode;
	}
	m_lastShownPopoveryType = kActionPopoverNone;
	[m_popoverController release];
	m_popoverController = nil;
}

- (void)hideMenuPopover {
    
    if (IS_IPAD) {
        if (m_popoverController) {
            [m_popoverController dismissPopoverAnimated:YES];
            [m_popoverController release];
            m_popoverController = nil;
        }
        
        m_lastShownPopoveryType = kActionPopoverNone;
    }
}

#pragma mark - PdfDelegate

- (void)jumpToPage:(int)page
{
	[m_pdfView setZoomScale:1];
	m_currentPage = page;
	float y = (page)*m_pdfView.contentSize.height / CGPDFDocumentGetNumberOfPages(m_currentDocumentRef);
	[m_pdfView setContentOffset:CGPointMake(0, y) animated:NO];
}

#pragma mark -- Bookmarks

- (void)openBookmark:(int)bookmarkNumber
{
	NSMutableArray *bookmarks = [m_document bookmarks];
	if ([bookmarks count] > bookmarkNumber) {
		Bookmark *bookmark = [bookmarks objectAtIndex:bookmarkNumber];
		[self jumpToBookmark:bookmark];
	}
}

- (void)jumpToBookmark:(Bookmark *)bookmark
{
	m_currentPage = bookmark.page;
	[m_pdfView setContentOffset:bookmark.offset animated:NO];
}

- (void)addBookmark
{
	NSString *bookmarkName = NSLocalizedString(@"Новая закладка", nil);
	NSMutableArray *bookmarks = [m_document bookmarks];
	if ([bookmarks count]) {
		bookmarkName = [bookmarkName stringByAppendingFormat:@" %d",[bookmarks count]];
	}
	Bookmark *bookmark = [[Bookmark alloc] initWithName:bookmarkName offset:[m_pdfView contentOffset]];
	bookmark.page = m_currentPage;
	[bookmarks addObject:bookmark];
}

- (void)removeBookmarkWithIndex:(int)index
{
	NSMutableArray *bookmarks = [m_document bookmarks];
	if ([bookmarks count] > index) {
		[bookmarks removeObjectAtIndex:index];
	}
}


- (int)bookmarksCount
{
	return [[m_document bookmarks] count];
}

- (Bookmark *)bookmarkAtIndex:(int)index
{
	NSMutableArray *bookmarks = [m_document bookmarks];
	if ([bookmarks count] > index) {
		return [bookmarks objectAtIndex:index];
	}
	return nil;
}

- (int)currentPage
{
	return m_currentPage;
}

- (int)pagesCount
{
	int result = CGPDFDocumentGetNumberOfPages(m_currentDocumentRef);
	return result;
}

#pragma mark -- Notes

- (void)addNote:(CGPoint)point withText:(NSString *)text timestamp:(NSTimeInterval)timestamp
{
	Note *note = [[Note alloc] initWithText:text offset:point];
	note.timestamp = timestamp;
	NSMutableArray *notes = [m_document notes];
	[notes addObject:note];
	m_mode = kReadMode;
	UIButton *noteView = [UIButton buttonWithType:UIButtonTypeCustom];
	[noteView setImage:[UIImage imageNamed:@"note.png"] forState:UIControlStateNormal];
	[noteView addTarget:self action:@selector(editNoteAction:) forControlEvents:UIControlEventTouchUpInside];
	noteView.tag = [m_notesViews count];
	[m_notesViews addObject:noteView];
	[self saveDocument];
	float scale = m_pdfView.zoomScale;
	noteView.frame = CGRectMake(note.offset.x*scale-12, note.offset.y*scale-12, 24, 24);
	[m_pdfView addSubview:noteView];
	[self.view endEditing:YES];
	if (IS_IPAD) {
		[m_popoverController dismissPopoverAnimated:YES];
	}
	m_lastShownPopoveryType = kActionPopoverNone;
}

- (void)editNoteAction:(id)sender
{
	NSMutableArray *notes = [m_document notes];
	Note *note = [notes objectAtIndex:[(UIButton *)sender tag]];
	if (m_popoverController) {
		[m_popoverController dismissPopoverAnimated:YES];
		[m_popoverController release];
		m_popoverController = nil;
	}
	if (IS_IPAD) {
		if (m_lastShownPopoveryType != kActionPopoverNotes) {
			m_lastShownPopoveryType = kActionPopoverNotes;
			AddNoteDialog *ctl = [[AddNoteDialog alloc] init];
			ctl.noteIndex = [(UIButton *)sender tag];
			ctl.mode = kNoteDialogEditNote;
			ctl.point = note.offset;
			ctl.text = note.text;
			ctl.timestamp = note.timestamp;
			[ctl refresh];
			ctl.delegate = self;
			ctl.contentSizeForViewInPopover = CGSizeMake(300.0, 200.0);
			UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
			m_popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
			m_popoverController.delegate = self;
			[m_popoverController presentPopoverFromRect:CGRectMake(note.offset.x, note.offset.y, 1, 1)
												 inView:m_pdfView
							   permittedArrowDirections:UIPopoverArrowDirectionAny
											   animated:YES];
		}
		else {
			m_lastShownPopoveryType = kActionPopoverNone;
		}
	} else {
		if (m_lastShownPopoveryType != kActionPopoverNotes) {
			m_lastShownPopoveryType = kActionPopoverNotes;
			AddNoteDialog *ctl = [[[AddNoteDialog alloc] init] autorelease];
			ctl.noteIndex = [(UIButton *)sender tag];
			ctl.mode = kNoteDialogEditNote;
			ctl.point = note.offset;
			ctl.text = note.text;
			ctl.timestamp = note.timestamp;
			[ctl refresh];
			ctl.delegate = self;
			
			UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
			
			[self presentViewController:navController animated:YES completion:nil];
		}
		else {
			m_lastShownPopoveryType = kActionPopoverNone;
		}
	}
	
}

- (void)editNoteAtIndex:(int)index point:(CGPoint)point text:(NSString *)text timestamp:(NSTimeInterval)timestamp
{
	NSMutableArray *notes = [m_document notes];
	if (index < [notes count]) {
		Note *note = [notes objectAtIndex:index];
		note.text = text;
		note.offset = point;
		note.timestamp = timestamp;
		float scale = m_pdfView.zoomScale;
		UIButton *noteView = [m_notesViews objectAtIndex:index];
		noteView.frame = CGRectMake(note.offset.x*scale-12, note.offset.y*scale-12, 24, 24);
		[self saveDocument];
	}
	m_mode = kReadMode;
	[self.view endEditing:YES];
	[m_popoverController dismissPopoverAnimated:YES];
	m_lastShownPopoveryType = kActionPopoverNone;
}

- (void)removeNoteWithIndex:(int)index
{
	NSMutableArray *notes = [m_document notes];
	if (index < [notes count]) {
		[notes removeObjectAtIndex:index];
	}
	if (index < [m_notesViews count]) {
		[[m_notesViews objectAtIndex:index] removeFromSuperview];
		[m_notesViews removeObjectAtIndex:index];
	}
	[self saveDocument];
}

- (int)notesCount
{
	return [[m_document notes] count];
}

- (Note *)noteByIndex:(int)index
{
	Note *note = nil;
	if (index < [[m_document notes] count]) {
		note = [[m_document notes] objectAtIndex:index];
	}
	return note;
}

- (void)cancelNote
{
	m_mode = kReadMode;
	[m_popoverController dismissPopoverAnimated:YES];
	m_lastShownPopoveryType = kActionPopoverNone;
	[self.view endEditing:YES];
}

- (void)openNoteAtIndex:(int)index
{
	NSMutableArray *notes = [m_document notes];
	if ([notes count] < index) return;
	Note *note = [notes objectAtIndex:index];
	[m_pdfView setZoomScale:1];
	float contentOffsetY = note.offset.y - m_pdfView.frame.size.height/2;
	if (contentOffsetY < 0) {
		contentOffsetY = 0;
	}
	if (contentOffsetY > (m_pdfView.contentSize.height - m_pdfView.frame.size.height)) {
		contentOffsetY = (m_pdfView.contentSize.height - m_pdfView.frame.size.height);
	}
	[m_pdfView setContentOffset:CGPointMake(0, contentOffsetY) animated:NO];
	if (m_popoverController) {
		[m_popoverController dismissPopoverAnimated:YES];
		[m_popoverController release];
		m_popoverController = nil;
	}
	
	if (IS_IPAD) {
		if (m_lastShownPopoveryType != kActionPopoverNotes) {
			m_lastShownPopoveryType = kActionPopoverNotes;
			AddNoteDialog *ctl = [[AddNoteDialog alloc] init];
			ctl.noteIndex = index;
			ctl.mode = kNoteDialogEditNote;
			ctl.point = note.offset;
			ctl.text = note.text;
			ctl.timestamp = note.timestamp;
			[ctl refresh];
			ctl.delegate = self;
			ctl.contentSizeForViewInPopover = CGSizeMake(300.0, 200.0);
			UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
			m_popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
			m_popoverController.delegate = self;
			[m_popoverController presentPopoverFromRect:CGRectMake(note.offset.x, note.offset.y, 1, 1)
												 inView:m_pdfView
							   permittedArrowDirections:UIPopoverArrowDirectionAny
											   animated:YES];
		}
		else {
			m_lastShownPopoveryType = kActionPopoverNone;
		}
	} else {
		if (m_lastShownPopoveryType != kActionPopoverNotes) {
			m_lastShownPopoveryType = kActionPopoverNotes;
			AddNoteDialog *ctl = [[AddNoteDialog alloc] init];
			ctl.noteIndex = index;
			ctl.mode = kNoteDialogEditNote;
			ctl.point = note.offset;
			ctl.text = note.text;
			ctl.timestamp = note.timestamp;
			[ctl refresh];
			ctl.delegate = self;
			ctl.contentSizeForViewInPopover = CGSizeMake(300.0, 200.0);
			UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
			
			[self presentViewController:navController animated:YES completion:nil];
		}
		else {
			m_lastShownPopoveryType = kActionPopoverNone;
		}
	}
	
	
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return m_pdfView.contentView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
	NSMutableArray *notes = [m_document notes];
	int pagesCount = CGPDFDocumentGetNumberOfPages(m_currentDocumentRef);
	float pxPP = m_pdfView.contentSize.height / pagesCount;
	float scale = m_pdfView.zoomScale;
	for (int i = 0; i < [notes count]; i++) {
		Note *note = [notes objectAtIndex:i];
		UIButton *noteView = [m_notesViews objectAtIndex:i];
		if (fabs(note.offset.y*scale - m_pdfView.contentOffset.y) <= pxPP) {
			noteView.hidden = NO;
			noteView.frame = CGRectMake(note.offset.x*scale-12, note.offset.y*scale-12, 24, 24);
		} else {
			noteView.hidden = YES;
		}
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	m_slider.value = 100 * scrollView.contentOffset.y / (scrollView.contentSize.height - self.view.frame.size.height);
	
	float pxPerPage = (scrollView.contentSize.height - 5)/ CGPDFDocumentGetNumberOfPages(m_currentDocumentRef);
	m_currentPage = (int)(scrollView.contentOffset.y/pxPerPage + 0.5);
	
	NSMutableArray *notes = [m_document notes];
	int pagesCount = CGPDFDocumentGetNumberOfPages(m_currentDocumentRef);
	float pxPP = m_pdfView.contentSize.height / pagesCount;
	float scale = m_pdfView.zoomScale;
	for (int i = 0; i < [notes count]; i++) {
		Note *note = [notes objectAtIndex:i];
		UIButton *noteView = [m_notesViews objectAtIndex:i];
		if (fabs(note.offset.y - m_pdfView.contentOffset.y) <= pxPP) {
			noteView.hidden = NO;
			noteView.frame = CGRectMake(note.offset.x*scale-12, note.offset.y*scale-12, 24, 24);
		} else {
			noteView.hidden = YES;
		}
	}
	
	m_bookmarkButtonItem.image = [UIImage imageNamed:@"bookmarkUnselected.png"];
	NSMutableArray *bookmarks = [m_document bookmarks];
	for (Bookmark *i in bookmarks) {
		if (fabs(i.offset.y - m_pdfView.contentOffset.y) <= pxPP) {
			m_bookmarkButtonItem.image = [UIImage imageNamed:@"bookmarkSelected.png"];
		}
	}
	[scrollView layoutSubviews];
	[m_pdfView showPageLabel:YES];
	
	[m_pageNumberLabelTimer invalidate];
	m_pageNumberLabelTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(hidePageLabel) userInfo:nil repeats:NO];
}

- (void)tapAction:(id)sender
{
	[self hidePageLabel];
	
	if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
		if ([(UITapGestureRecognizer *)sender numberOfTouches] == 1) {
			if (m_mode == kReadMode) {
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:2];
				[UIView setAnimationDelay:0];
				[m_slider setHidden:!m_slider.hidden];
				[UIView commitAnimations];
			}
			if (m_mode == kNoteMode) {
				CGPoint tapPoint = [sender locationInView:m_pdfView];
				tapPoint.x = tapPoint.x/m_pdfView.zoomScale;
				tapPoint.y = tapPoint.y/m_pdfView.zoomScale;
				if (IS_IPAD) {
					if (m_popoverController) {
						[m_popoverController dismissPopoverAnimated:YES];
						[m_popoverController release];
						m_popoverController = nil;
					}
					if (m_lastShownPopoveryType != kActionPopoverNotes) {
						m_lastShownPopoveryType = kActionPopoverNotes;
						AddNoteDialog *ctl = [[[AddNoteDialog alloc] init] autorelease];
						ctl.mode = kNoteDialogNewNote;
						ctl.delegate = self;
						ctl.point = tapPoint;
						[ctl reset];
						ctl.contentSizeForViewInPopover = CGSizeMake(300.0, 200.0);
						ctl.delegate = self;
						UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
						m_popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
						m_popoverController.delegate = self;
						[m_popoverController presentPopoverFromRect:CGRectMake(tapPoint.x*m_pdfView.zoomScale,
																			   tapPoint.y*m_pdfView.zoomScale, 1, 1)
															 inView:m_pdfView
										   permittedArrowDirections:UIPopoverArrowDirectionAny
														   animated:YES];
					}
					else {
						m_lastShownPopoveryType = kActionPopoverNone;
					}
				} else {
					AddNoteDialog *ctl = [[[AddNoteDialog alloc] init] autorelease];
					ctl.mode = kNoteDialogNewNote;
					ctl.delegate = self;
					ctl.point = tapPoint;
					[ctl reset];
					ctl.contentSizeForViewInPopover = CGSizeMake(300.0, 200.0);
					ctl.delegate = self;
					UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
					[self presentViewController:navController animated:YES completion:nil];
				}
				
			}
		}
	}
}

- (void)hidePageLabel
{
	[m_pdfView showPageLabel:NO];
	[m_pageNumberLabelTimer invalidate];
	m_pageNumberLabelTimer = nil;
}

@end
