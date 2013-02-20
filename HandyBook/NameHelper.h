//
//  NameHelper.h
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameHelper : NSObject

+ (NSString *)nameForSubjectWithIndex:(int)index;
+ (NSString *)allForSubjectWithIndex:(int)index;

@end
