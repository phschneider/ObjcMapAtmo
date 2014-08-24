//
// Created by pschneider on 23.11.13.
//
// Copyright (c) 2013 Haus & Gross communications. All rights reserved.
//


#import <Foundation/Foundation.h>


@class NXOAuth2Account;
@interface PSMapAtmoAccount : NSObject

+ (PSMapAtmoAccount *) sharedInstance;

- (BOOL)hasAccount;
- (BOOL)accountIsValid:(NXOAuth2Account*)oAuthAccount;
- (BOOL)currentAccountIsValid;

- (NXOAuth2Account*) account;

- (void) requestAccount;
- (void) requestAccountWithUser:(NSString*)user andPass:(NSString*)pass;
- (void) requestAccountWithPreparedAuthorizationURLHandler;

@end