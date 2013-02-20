//
//  StartViewController.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 18.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "StartViewController.h"
#import "ClassViewController.h"
#import "MainViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *imageName = @"startScreen";
	if (SCREENHEIGHT == IPADHEIGHT) {
		imageName = [imageName stringByAppendingString:@"-iPad"];
	} else if (SCREENHEIGHT == IPHONE5HEIGHT) {
		imageName = [imageName stringByAppendingString:@"-568h"];
	}
	if (ISRETINA) {
		imageName = [imageName stringByAppendingString:@"@2x"];
	}
	imageName = [imageName stringByAppendingString:@".png"];
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	imageView.frame = self.view.bounds;
	[self.view addSubview:imageView];

	ClassViewController *classVC = [[ClassViewController alloc] initWithStyle:UITableViewStylePlain];
	m_mainVC = [[MainViewController alloc] initWithRootViewController:classVC];
	
	[self performSelectorInBackground:@selector(updateCatalog) withObject:nil];
	
	m_timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(push) userInfo:nil repeats:NO];
	[self performSelectorInBackground:@selector(updateCatalog) withObject:nil];
}

- (void)updateCatalog
{
	NSURL *url = [NSURL URLWithString:[SERVERURL stringByAppendingString:@"archive.xml"]];
	NSData *data = [NSData dataWithContentsOfURL:url];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *fileName = [documentsDirectory stringByAppendingString:@"/archive.xml"];
	if (data.length > 10000) {
		BOOL success = [data writeToFile:fileName atomically:YES];
		if (success) {
			[[NSNotificationCenter defaultCenter] postNotificationName:CATALOGUPDATED object:nil];
		}
	}
}

- (void)push
{
	[m_timer invalidate];
	[self presentModalViewController:m_mainVC animated:YES];
}

- (void)startParse
{
	NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"archive.xml" ofType:nil]];
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

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"archive"]) {
		int version = [[attributeDict objectForKey:@"v"] intValue];
		if ([[NSUserDefaults standardUserDefaults] integerForKey:@"catalogVersion"] < version) {
			[[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"catalogVersion"];
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
	
}


@end
