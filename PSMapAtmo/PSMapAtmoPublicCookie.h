//
// Created by Philip Schneider on 18.01.15.
// Copyright (c) 2015 phschneider.net. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSMapAtmoPublicCookie : NSObject
+ (PSMapAtmoPublicCookie *)sharedInstance;
- (void)saveCookieFromResponse:(NSHTTPURLResponse *)response;
- (BOOL)cookieIsValid;
- (void)checkAndRequestCookieIfNeeded;
- (NSString *)httpHeaderCookie;
- (NSString *)cookieValue;
@end