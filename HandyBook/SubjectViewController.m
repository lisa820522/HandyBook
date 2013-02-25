//
//  ClassViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "SubjectViewController.h"

#import "MainViewController.h"
#import "CategoryViewController.h"

@implementation SubjectViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startParse) name:CATALOGUPDATED object:nil];
		m_inParsing = NO;
    }
    return self;
}

- (void)dealloc
{
	[m_activityView release];
	[m_keys release];
	[m_lockView release];
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
	
	m_lockView = [[UIView alloc] initWithFrame:self.view.bounds];
	m_lockView.backgroundColor = [UIColor blackColor];
	[self.navigationController.navigationBar addSubview:m_lockView];
	m_activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 44) / 2, (self.view.frame.size.height - 44) / 2, 44, 44)];
	m_activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	[m_lockView addSubview:m_activityView];
	m_lockView.hidden = YES;
	
	[self setNavigationBar];
	
	[self performSelectorInBackground:@selector(updateCatalog) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	((MainViewController *)self.navigationController).titleLabel.text = @"Каталог";
}

- (void)setNavigationBar
{
	NSString *imageName = @"refresh";
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
	
    button.frame = CGRectMake(0, 7, 35, 30);
	
    [button addTarget:self action:@selector(updateCatalog) forControlEvents:UIControlEventTouchUpInside];
	
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = customBarItem;
	
    [customBarItem release];
}

- (void)startParse
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"archive.xml"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
	
	NSURL *url = nil;
	
//	if (fileExists) {
//		url = [NSURL fileURLWithPath:fileName];
//	} else {
		url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"archive.xml" ofType:nil]];
//	}
	
	if (!m_inParsing) {
		m_inParsing = YES;
		
		NSData *fileData = [NSData dataWithContentsOfURL:url];
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

- (void)updateCatalog
{
	if (m_lockView.hidden) {
		[self performSelectorOnMainThread:@selector(showActivity) withObject:nil waitUntilDone:YES];
		
		NSURL *url = [NSURL URLWithString:[SERVERURL stringByAppendingString:@"archive.xml"]];
		NSData *data = [NSData dataWithContentsOfURL:url];
		NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *fileName = [documentsDirectory stringByAppendingPathComponent:@"archive.xml"];
		if (data.length > 10000) {
			[data writeToFile:fileName atomically:YES];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:CATALOGUPDATED object:nil];
	}
}

- (void)catalogUpdated
{
	m_lockView.hidden = YES;
	[m_activityView stopAnimating];
	[self.tableView reloadData];
}

- (void)showActivity
{
	[m_activityView startAnimating];
	m_lockView.hidden = NO;
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"archive"]) {
		m_catalog = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqualToString:@"subject"]) {
		NSMutableDictionary *subject = [NSMutableDictionary dictionary];
		m_currentSubject = [attributeDict objectForKey:@"name"];
		[m_catalog setObject:subject forKey:m_currentSubject];
	} else if ([elementName isEqualToString:@"category"]) {
		NSMutableArray *category = [NSMutableArray array];
		m_currentCategory = [attributeDict objectForKey:@"name"];
		[[m_catalog objectForKey:m_currentSubject] setObject:category forKey:m_currentCategory];
	} else if ([elementName isEqualToString:@"item"]) {
		[[[m_catalog objectForKey:m_currentSubject] objectForKey:m_currentCategory] addObject:[attributeDict retain]];
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
	m_inParsing = NO;
	if (m_keys) {
		[m_keys release];
	}
	m_keys = [[m_catalog allKeys] retain];
	[self performSelectorOnMainThread:@selector(catalogUpdated) withObject:nil waitUntilDone:YES];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.textLabel.text = [NSString stringWithFormat:@"• %@",[m_keys objectAtIndex:[indexPath row]]];
	cell.textLabel.textColor = [UIColor blackColor];
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
    CategoryViewController *ctl = [[CategoryViewController alloc] initWithStyle:UITableViewStylePlain];
	ctl.categories = [m_catalog objectForKey:[m_keys objectAtIndex:[indexPath row]]];
	((MainViewController *)self.navigationController).titleLabel.text = [m_keys objectAtIndex:[indexPath row]];
	[self.navigationController pushViewController:ctl animated:YES];
	[ctl release];
}

@end
