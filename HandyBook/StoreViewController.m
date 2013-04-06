//
//  StoreViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "StoreViewController.h"

#import "NameHelper.h"
#import <StoreKit/StoreKit.h>

#define PRODUCTWIDTH 190
#define PRICEWIDTH 110
#define INFOWIDTH 100
#define MARGIN 10
#define BUTTONHEIGHT 88
#define LABELHEIGHT 44

@implementation StoreViewController

@synthesize bookID;
@synthesize info;
@synthesize bookName;

static StoreViewController *m_sharedInstance = nil;

+ (StoreViewController *)sharedInstance
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
	[m_bookLabel release];
	[m_infoLabel release];
	[m_bookPrice release];
	[m_allPrice release];
	[m_priceFormatter release];
	[m_products release];
	[m_activityView release];
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
	
	// Backgound
	
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
	self.view.backgroundColor = backgroundColor;
	
	imageName = @"toolbar";
	if (SCREENHEIGHT == 1024) {
		imageName = [imageName stringByAppendingString:@"-iPad"];
	}
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
	UIImage *image = [UIImage imageNamed:imageName];
	image = [UIImage imageWithCGImage:[image CGImage] scale:2 orientation:UIImageOrientationDown];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	[imageView setFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[self.view addSubview:imageView];
	[imageView release];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
	[button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
	
	UILabel *buttonLabel = [[UILabel alloc] initWithFrame:button.bounds];
	buttonLabel.backgroundColor = [UIColor clearColor];
	buttonLabel.textAlignment = UITextAlignmentCenter;
	buttonLabel.textColor = [UIColor blackColor];
	buttonLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
	buttonLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    buttonLabel.shadowOffset = CGSizeMake(0, -1.0);
	buttonLabel.text = @"Отмена";
	
	[button addSubview:buttonLabel];
	[buttonLabel release];
	
	[self.view addSubview:button];
	
	// Products buttons
	
	// Book button
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = [UIColor clearColor];
	button.frame = CGRectMake(0, 40, self.view.frame.size.width, BUTTONHEIGHT);
	[button addTarget:self action:@selector(buyBook) forControlEvents:UIControlEventTouchUpInside];
	
	BOOL isIpad = NO;
	
	if (SCREENHEIGHT == IPADHEIGHT) {
		isIpad = YES;
	}
	
	m_bookLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, 0, button.frame.size.width - 2*MARGIN, 44)];
	[self configureLabel:m_bookLabel left:YES];
	m_bookLabel.numberOfLines = 1;
	m_bookLabel.text = @"Книга";
	[button addSubview:m_bookLabel];
	
	m_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, LABELHEIGHT,
															button.frame.size.width - PRICEWIDTH - 2*MARGIN - isIpad*50, 44)];
	[self configureLabel:m_infoLabel left:YES];
	m_infoLabel.textColor = [UIColor grayColor];
	m_infoLabel.numberOfLines = 1;
	m_infoLabel.font = [UIFont fontWithName:@"StudioScriptCTT" size:19];
	m_infoLabel.text = @"Автор";
	[button addSubview:m_infoLabel];
	
	m_bookPrice = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.width - MARGIN - PRICEWIDTH - isIpad*50, LABELHEIGHT, PRICEWIDTH + isIpad*50, LABELHEIGHT)];
	[self configureLabel:m_bookPrice left:NO];
	if (SCREENHEIGHT == IPADHEIGHT) {
		m_bookPrice.font = [UIFont fontWithName:@"StudioScriptCTT" size:25];
	} else {
		m_bookPrice.font = [UIFont fontWithName:@"StudioScriptCTT" size:20];
	}
	m_bookPrice.textColor = [UIColor colorWithRed:71/255.0 green:156/255.0 blue:59/255.0 alpha:1];
	m_bookPrice.text = @"";
	[button addSubview:m_bookPrice];
	[self.view addSubview:button];
	
	// All books button
	
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = [UIColor clearColor];
	button.frame = CGRectMake(0, 40 + BUTTONHEIGHT + 10, self.view.frame.size.width, 88);
	[button addTarget:self action:@selector(buyAll) forControlEvents:UIControlEventTouchUpInside];
	
	buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, 0,
															button.frame.size.width - PRICEWIDTH - 2*MARGIN - isIpad*50, LABELHEIGHT*2)];
	[self configureLabel:buttonLabel left:YES];
	buttonLabel.text = @"Все книги";
	[button addSubview:buttonLabel];
	
	m_allPrice = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.size.width - PRICEWIDTH - MARGIN - isIpad*50, 0, PRICEWIDTH + isIpad*50, 88)];
	[self configureLabel:m_allPrice left:NO];
	if (SCREENHEIGHT == IPADHEIGHT) {
		m_allPrice.font = [UIFont fontWithName:@"StudioScriptCTT" size:25];
	} else {
		m_allPrice.font = [UIFont fontWithName:@"StudioScriptCTT" size:20];
	}
	m_allPrice.textColor = [UIColor colorWithRed:208/255.0 green:48/255.0 blue:43/255.0 alpha:1];
	m_allPrice.text = @"";
	[button addSubview:m_allPrice];
	[self.view addSubview:button];
	
	// PriceFormatter
	m_priceFormatter = [[NSNumberFormatter alloc] init];
    [m_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [m_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(transactionFailed:) name:IAPHelperTransactionFailedNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"Paid"]) {
		[self performSelectorInBackground:@selector(checkPaid) withObject:nil];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	m_bookIdentifier = [@"com.geliskhanov.HandyBook." stringByAppendingString:self.bookID];
	NSSet *identifiers = [[NSSet alloc] initWithObjects:m_bookIdentifier, @"com.geliskhanov.HandyBook.allBooks", nil];
	m_IAPHelper = [[IAPHelper alloc] initWithProductIdentifiers:identifiers];
	[self reload];
	
	m_bookLabel.text = self.bookName;
	m_infoLabel.text = self.info;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	m_activityView.hidden = YES;
	[m_activityView stopAnimating];
}

- (void)checkPaid
{
	NSData *fileData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://grampe.p.ht/paid.xml"]];
	if (fileData) {
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:fileData];
		[parser setDelegate:self];
		[parser setShouldProcessNamespaces:NO];
		[parser setShouldReportNamespacePrefixes:NO];
		[parser setShouldResolveExternalEntities:NO];
		
		[parser parse];
		
		if ([parser parserError]) {
			DLog(@"error\n%@\n",[parser parserError]);
		}
		[parser release];
	}
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"app"]) {
		if ([[attributeDict objectForKey:@"id"] isEqualToString:@"com.geliskhanov.HandyBook"]) {
			if ([[attributeDict objectForKey:@"status"] isEqualToString:@"1"]) {
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Paid"];
			}
		}
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
{
	
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	assert([[NSUserDefaults standardUserDefaults] boolForKey:@"Paid"]);
}


- (void)cancel
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)buyBook
{
	if (m_activityView.hidden) {
		m_activityView.hidden = NO;
		[m_activityView startAnimating];
		SKProduct *product = [self productWithIdentifier:m_bookIdentifier];
		DLog(@"Buying %@...", product.productIdentifier);
		[m_IAPHelper buyProduct:product];
	}
}

- (void)buyAll
{
	if (m_activityView.hidden) {
		m_activityView.hidden = NO;
		[m_activityView startAnimating];
		SKProduct *product = [self productWithIdentifier:@"com.geliskhanov.HandyBook.allBooks"];
		DLog(@"Buying %@...", product.productIdentifier);
		[m_IAPHelper buyProduct:product];
	}
}

- (void)reload
{
	if (!m_activityView) {
		m_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		m_activityView.frame = CGRectMake(self.view.center.x - 30, self.view.center.y - 30, 60, 60);
		[self.view addSubview:m_activityView];
	}
	m_activityView.hidden = NO;
	[m_activityView startAnimating];
	
	if (m_products) {
		[m_products release];
	}
    m_products = nil;
    [m_IAPHelper requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            m_products = [products retain];
			SKProduct *product = [self productWithIdentifier:m_bookIdentifier];
			[m_priceFormatter setLocale:product.priceLocale];
			m_bookPrice.text = [m_priceFormatter stringFromNumber:product.price];
			product = [self productWithIdentifier:@"com.geliskhanov.HandyBook.allBooks"];
			[m_priceFormatter setLocale:product.priceLocale];
			m_allPrice.text = [m_priceFormatter stringFromNumber:product.price];
        }
		[m_activityView stopAnimating];
		m_activityView.hidden = YES;
    }];
}

- (void)configureLabel:(UILabel *)label left:(BOOL)left;
{
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = left?UITextAlignmentLeft:UITextAlignmentRight;
	label.textColor = [UIColor blackColor];
	label.font = [UIFont fontWithName:@"StudioScriptCTT" size:25];
	label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    label.shadowOffset = CGSizeMake(0, -1.0);
}

- (SKProduct *)productWithIdentifier:(NSString *)identifier
{
	for (SKProduct *i in m_products) {
		if ([i.productIdentifier isEqualToString:identifier]) {
			return i;
		}
	}
	return nil;
}

- (void)transactionFailed:(NSNotification *)notification
{
	[m_activityView stopAnimating];
	m_activityView.hidden = YES;
}

@end
