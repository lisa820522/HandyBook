//
//  GDZIAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "GDZIAPHelper.h"

@implementation GDZIAPHelper

+ (GDZIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static GDZIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.geliskhanov.HandyBook.allBooks",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
