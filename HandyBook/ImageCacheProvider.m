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
		image = [m_imagesDict objectForKey:key];
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
			if (image) {
				[m_imagesDict setObject:image forKey:key];
			} else {
				image = [self loadFile:key];
			}
		} else {
			image = [self loadFile:key];
		}
	}
	return image;
}

- (UIImage *)loadFile:(NSString *)key
{
	UIImage *image = nil;
	NSString *fileName = [key stringByAppendingString:@".jpg"];
	NSString *filePath = [m_docPath stringByAppendingPathComponent:fileName];
	filePath = [[NSBundle mainBundle] pathForResource:key ofType:@".jpg"];
	if (filePath) {
		image = [UIImage imageWithContentsOfFile:filePath];
		[m_imagesDict setObject:image forKey:key];
	} else {
		[m_keysInProcess addObject:key];
		[self performSelectorInBackground:@selector(loadImageForKey:) withObject:key];
	}
	return image;
}

- (void)loadImageForKey:(NSString *)key
{
	NSURL *url = [NSURL URLWithString:[SERVERURL stringByAppendingFormat:@"%@.jpg", key]];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		if (![response.MIMEType isEqualToString:@"image/jpeg"]) {
			NSString *fileName = [key stringByAppendingString:@".jpg"];
			NSString *filePath = [m_docPath stringByAppendingPathComponent:fileName];
			[data writeToFile:filePath atomically:YES];
			NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
			[self addSkipBackupAttributeToItemAtURL:url];
			UIImage *image = [UIImage imageWithData:data];
			if (image) {
				[m_imagesDict setObject:image forKey:key];
				[m_keysInProcess removeObjectIdenticalTo:key];
			} else {
				[m_imagesDict setObject:[UIImage imageNamed:@"blank.png"] forKey:key];
			}
		} else {
			[m_imagesDict setObject:[UIImage imageNamed:@"blank.png"] forKey:key];
		}
		[self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:YES];
	}];	
}

- (void)update
{
	[self.delegate updateImage];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
	
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool: YES]
                                  forKey:NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end
