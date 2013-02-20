//
//  ClassViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "ClassViewController.h"

#import "MainViewController.h"
#import "SubjectViewController.h"

@implementation ClassViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCatalog) name:CATALOGUPDATED object:nil];
		m_inParsing = NO;
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
	
	[self startParse];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	((MainViewController *)self.navigationController).titleLabel.text = @"ГДЗ";
}

- (void)setNavigationBar
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoDark];
	
    button.frame = CGRectMake(0, 0, 43, 26);
	
    [button addTarget:self action:@selector(help) forControlEvents:UIControlEventTouchUpInside];
	
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = customBarItem;
	
    [customBarItem release];
}

- (void)help
{
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *ctl = [[MFMailComposeViewController alloc] init];
		ctl.mailComposeDelegate = self;
		NSArray *toRecipients = [NSArray arrayWithObject:@"igrampe@gmail.com"];
        [ctl setToRecipients:toRecipients];
		[ctl setSubject:@"Обратная связь | ГДЗ"];
		[self presentModalViewController:ctl animated:YES];
		[ctl release];
	} else {
		[self showErrorMessage];
	}
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    
    [self dismissModalViewControllerAnimated:YES];
	if (result == MFMailComposeResultSent) {
		
	}
}

- (void)showSuccessMessage
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Спасибо!"
                                                    message:@"Мы постараемся ответить Вам в ближайшее время"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)showErrorMessage
{    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Почтовый аккаунт не настроен"
                                                    message:@"Пожалуйста, настройте почтовый аккаунт"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)startParse
{
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingString:@"/archive.xml"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
	
	NSURL *url = nil;
	
	if (fileExists) {
		url = [NSURL fileURLWithPath:fileName];
	} else {
		url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"archive.xml" ofType:nil]];
	}
	
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
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingString:@"/archive.xml"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
	
	if (fileExists && !m_inParsing) {
		m_inParsing = YES;
		NSURL *url = [NSURL fileURLWithPath:fileName];
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

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"archive"]) {
		m_catalog = [[NSMutableDictionary alloc] init];
	} else if ([elementName isEqualToString:@"class"]) {
		NSMutableDictionary *class = [NSMutableDictionary dictionary];
		m_currentClassID = [attributeDict objectForKey:@"id"];
		[m_catalog setObject:class forKey:m_currentClassID];
	} else if ([elementName isEqualToString:@"subject"]) {
		NSMutableArray *subject = [NSMutableArray array];
		m_currentSubjectID = [attributeDict objectForKey:@"id"];
		[[m_catalog objectForKey:m_currentClassID] setObject:subject forKey:m_currentSubjectID];
	} else if ([elementName isEqualToString:@"item"]) {
		[[[m_catalog objectForKey:m_currentClassID] objectForKey:m_currentSubjectID] addObject:[attributeDict retain]];
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
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.textLabel.text = [NSString stringWithFormat:@"• %d класс",[indexPath row]+5];
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
    SubjectViewController *ctl = [[SubjectViewController alloc] initWithStyle:UITableViewStylePlain];
	ctl.subjects = [m_catalog objectForKey:[NSString stringWithFormat:@"%d",([indexPath row] + 5)]];
	ctl.index = [indexPath row] + 5;
	[self.navigationController pushViewController:ctl animated:YES];
	[ctl release];
}

@end
