//
//  BooksViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "BooksViewController.h"

#import "MainViewController.h"
#import "NameHelper.h"
#import "PdfViewController.h"
#import "StoreViewController.h"
#import "PdfDownloader.h"
#import "BookCell.h"

@implementation BooksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
	
	m_cacheProvider = [[ImageCacheProvider alloc] init];
	m_cacheProvider.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	((MainViewController *)self.navigationController).titleLabel.text = self.category;
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
	m_cacheProvider.delegate = nil;
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.books count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) {
		cell = [[[BookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	[(BookCell *)cell setBook:[self.books objectAtIndex:[indexPath row]]];
	UIImage *img = [m_cacheProvider imageForKey:[((BookCell *)cell).book objectForKey:@"file"]];
	[((BookCell *)cell).thumbnailView setImage:img];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	m_bookID = [[self.books objectAtIndex:[indexPath row]] objectForKey:@"file"];
	[[PdfViewController sharedInstance] setName:[[self.books objectAtIndex:[indexPath row]] objectForKey:@"name"]];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:m_bookID] ||
		[[NSUserDefaults standardUserDefaults] boolForKey:@"allBooks"]) {
		[self openReader:m_bookID];
	} else {
		[[StoreViewController sharedInstance] setBookID:m_bookID];
		NSString *info = [[[self.books objectAtIndex:[indexPath row]] objectForKey:@"author"] stringByAppendingString:@", "];
		info = [info stringByAppendingString:[[self.books objectAtIndex:[indexPath row]] objectForKey:@"info"]];
		[[StoreViewController sharedInstance] setInfo:info];
		[[StoreViewController sharedInstance] setBookName:[[self.books objectAtIndex:[indexPath row]] objectForKey:@"name"]];
		[self presentModalViewController:[StoreViewController sharedInstance] animated:YES];
	}
}

- (void)openReader:(NSString *)key
{
	[[PdfViewController sharedInstance] setFileName:[key stringByAppendingString:@".pdf"]];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:[key stringByAppendingString:@".pdf"]];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
	if (fileExists) {
		[[PdfViewController sharedInstance] reloadDocument];
		[self.navigationController pushViewController:[PdfViewController sharedInstance] animated:YES];
	} else {
		[self showDownloader];
	}
}

- (void)showDownloader
{
	if (!m_progressView) {
		m_progressView = [[DownloadProgressView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 280)/2, (self.view.frame.size.height - 200)/2, 280, 200)];
		m_progressView.delegate = self;
		[self.view addSubview:m_progressView];
		[m_progressView hide];
	}
	[m_progressView show];
	
	[PdfDownloader sharedInstance].delegate = self;
	[[PdfDownloader sharedInstance] performSelectorInBackground:@selector(downloadFile:) withObject:[m_bookID stringByAppendingString:@".pdf"]];
	
/*	m_alert = [[DownloadProgressView alloc] initWithDelegate:self];
	[PdfDownloader sharedInstance].delegate = self;
	[[PdfDownloader sharedInstance] downloadFile:[m_bookID stringByAppendingString:@".pdf"]];
	[m_alert show];*/
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

}

- (void)cancelDownload
{
	[[PdfDownloader sharedInstance] cancelDownloading];
	[m_progressView hide];
}

#pragma mark - PdfDownloaderDelegate

- (void)downloadingFailed
{
	[m_progressView hide];
}

- (void)didReceiveDataSize:(float)size
{
	[m_progressView setTotalSize:size];
}
- (void)didReceiveDataWithSize:(float)size
{
	float downloadedSize = m_progressView.downloadedSize + size;
	[m_progressView setDownloadedSize:downloadedSize];
}

- (void)didFinishedWithData:(NSData *)data
{
	[m_progressView hide];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:[m_bookID stringByAppendingString:@".pdf"]];
	// Hack against fake data
	if ([data length] > 10000) {
		[data writeToFile:fileName atomically:YES];
		[self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:fileName]];
		[[PdfDownloader sharedInstance] freeMemory];
		[self openReader:m_bookID];
	} else {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Извините, файл не найден на сервере" delegate:self cancelButtonTitle:@"ОК" otherButtonTitles:nil];
		[errorAlert show];
	}
}

- (void)updateImage:(UIImage *)image forKey:(NSString *)key
{
	[self.tableView reloadData];
}

- (void)updateImage
{
	[self.tableView reloadData];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
	
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - Purchasing

- (void)productPurchased:(NSNotification *)notification
{
	NSString *productIdentifier = notification.object;
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
	[[StoreViewController sharedInstance] dismissModalViewControllerAnimated:YES];
	[self openReader:m_bookID];
}

@end
