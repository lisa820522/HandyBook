//
//  ImageCacheProvider.m
//  HandyBook
//
//  Created by Sema Belokovsky on 24.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "ImageCacheProvider.h"

@implementation ImageCacheProvider

@synthesize delegate;

- (id)init
{
	self = [super init];
	if (self) {
		m_docPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] retain];
		m_imagesDict = [[NSMutableDictionary alloc] init];
		m_keysInProcess = [[NSMutableArray alloc] init];
	}
	return self;
}

- (UIImage *)imageForKey:(NSString *)key
{
	UIImage *image = nil;
	if ([[m_imagesDict allKeys] containsObject:key]) {
		[m_imagesDict objectForKey:key];
	} else {
		if ([m_keysInProcess containsObject:key]) {
			return nil;
		}
		NSString *fileName = [key stringByAppendingString:@".jpg"];
		NSString *filePath = [m_docPath stringByAppendingPathComponent:fileName];
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
		if (fileExists) {
			NSData *data = [NSData dataWithContentsOfFile:filePath];
			image = [UIImage imageWithData:data];
			[m_imagesDict setObject:image forKey:key];
		} else {
			filePath = [[NSBundle mainBundle] pathForResource:key ofType:@".jpg"];
			if (filePath) {
				image = [UIImage imageWithContentsOfFile:filePath];
				[m_imagesDict setObject:image forKey:key];
			} else {
				[m_keysInProcess addObject:key];
				[self performSelector:@selector(loadImageForKey:) withObject:key];
			}
		}
	}
	return image;
}

- (void)loadImageForKey:(NSString *)key
{
	NSURL *url = [NSURL URLWithString:[SERVERURL stringByAppendingFormat:@"%@.jpg", key]];
	NSData *data = [NSData dataWithContentsOfURL:url];
	if (data.length > 1000) {
		NSString *fileName = [key stringByAppendingString:@".jpg"];
		NSString *filePath = [m_docPath stringByAppendingPathComponent:fileName];
		[data writeToFile:filePath atomically:YES];
		UIImage *image = [UIImage imageWithData:data];
		[m_imagesDict setObject:image forKey:key];
		[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];
	} else {
		[m_imagesDict setObject:[UIImage imageNamed:@"blank.png"] forKey:key];
	}
}

- (void)update
{
	[self.delegate updateImage];
}

@end
