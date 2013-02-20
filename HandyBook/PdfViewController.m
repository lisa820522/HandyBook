//
//  PdfViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "PdfViewController.h"
#import "MainViewController.h"

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
	[m_webView release];
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
	m_webView = [[UIWebView alloc] initWithFrame:CGRectZero];
	[[m_webView scrollView] setDelegate:self];
	[m_webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
	
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
	
	m_webView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:imageName]];
	m_webView.scalesPageToFit = YES;
	[m_webView setDelegate:self];
	[self.view addSubview:m_webView];
	
	UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleSlider)] autorelease];
	[m_webView addGestureRecognizer:tapRecognizer];
	
	[self setNavigationBar];
	
	m_slider = [[UISlider alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 44 - self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width - 20, 44)];
	m_slider.minimumValue = 0;
	m_slider.hidden = YES;
	[m_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:m_slider];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	m_slider.hidden = YES;
	((MainViewController *)self.navigationController).titleLabel.text = self.name;
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:self.fileName];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullPath];
	if (fileExists) {
		NSURL *url = [NSURL fileURLWithPath:fullPath];
		[m_webView loadRequest:[NSURLRequest requestWithURL:url]];
		m_slider.value = 0;
	} else {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Ощибка" message:@"Извините, произошла ошибка чтения файла" delegate:self cancelButtonTitle:@"ОК" otherButtonTitles:nil];
		[errorAlert show];
		[errorAlert release];
	}
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

- (void)sliderValueChanged:(id)sender
{
	UISlider *slider = (UISlider *)sender;
	[m_webView.scrollView setZoomScale:1];
	[m_webView.scrollView setContentOffset:CGPointMake(0, slider.value)];
}

- (void)toggleSlider
{
	m_slider.hidden = !m_slider.hidden;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	m_slider.value = m_webView.scrollView.contentOffset.y;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSilder) userInfo:nil repeats:NO];
}

- (void)updateSilder
{
	m_slider.maximumValue = m_webView.scrollView.contentSize.height - self.view.frame.size.height;
}

@end
