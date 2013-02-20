//
//  NameHelper.m
//  gdzBooks
//
//  Created by Sema Belokovsky on 17.02.13.
//  Copyright (c) 2013 Sema Belokovsky. All rights reserved.
//

#import "NameHelper.h"

@implementation NameHelper

+ (NSString *)nameForSubjectWithIndex:(int)index
{
	NSString *result = nil;
	switch (index) {
		case 0:
			result = @"Английский язык";
			break;
		case 1:
			result = @"Математика";
			break;
		case 2:
			result = @"Русский язык";
			break;
		case 3:
			result = @"Алгебра";
			break;
		case 4:
			result = @"Геометрия";
			break;
		case 5:
			result = @"Физика";
			break;
		case 6:
			result = @"Химия";
			break;
		case 7:
			result = @"Немецкий язык";
			break;
		default:
			break;
	}
	return result;
}

+ (NSString *)allForSubjectWithIndex:(int)index
{
	NSString *result;
	if (index == 0 || index == 2 || index == 7) {
		result = @"Весь";
	} else {
		result = @"Вся";
	}
	return result;
}

@end
