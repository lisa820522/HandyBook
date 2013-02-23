//
//  ImageCacheProvider.h
//  HandyBook
//
//  Created by Sema Belokovsky on 24.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageCacheDelegate <NSObject>

- (void)updateImage:(UIImage *)image forKey:(NSString *)key;
- (void)updateImage;

@end

@interface ImageCacheProvider : NSObject {
	NSMutableDictionary *m_imagesDict;
	NSString *m_docPath;
	NSMutableArray *m_keysInProcess;
}

@property (nonatomic, assign) id<ImageCacheDelegate> delegate;

- (UIImage *)imageForKey:(NSString *)key;

@end
