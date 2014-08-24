//
// Created by pschneider on 23.11.13.
//
// Copyright (c) 2013 Haus & Gross communications. All rights reserved.
//

#import <NXOAuth2Client/NXOAuth2.h>

#import "PSMapAtmoAccount.h"
#import "PSMapAtmo.h"

@interface PSMapAtmoAccount ()
@property (nonatomic, strong)  NXOAuth2Account  * oAuthAccount;
@end


@implementation PSMapAtmoAccount

static PSMapAtmoAccount * instance = nil;
+ (PSMapAtmoAccount *) sharedInstance {
    @synchronized (self)
    {
        if (instance == nil)
        {
            [PSMapAtmoAccount new];
        }
    }
    return instance;
}



- (id)init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        [[NXOAuth2AccountStore sharedStore] setClientID:CLIENT_ID
                                                 secret:CLIENT_SECRET
                                       authorizationURL:[NSURL URLWithString:AUTH_URL]
                                               tokenURL:[NSURL URLWithString:REQUEST_TOKEN]
                                            redirectURL:[NSURL URLWithString:@"http://dash.atmo"]
                                         forAccountType:ACCOUNT_TYPE];

        [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                          object:[NXOAuth2AccountStore sharedStore]
                                                            queue:nil
                                                      usingBlock:^(NSNotification *aNotification){
                                                          // Update your UI
                                                          [self checkAccounts];

                                                          self.oAuthAccount =  [[aNotification userInfo] objectForKey:@"NXOAuth2AccountStoreNewAccountUserInfoKey"];
                                                          NSLog(@"%@",[[aNotification userInfo] objectForKey:@"NXOAuth2AccountStoreNewAccountUserInfoKey"]);

                                                          [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_ACCOUNT_UPDATE_NOTIFICATION object:nil];
                                                      }];

        [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                          object:[NXOAuth2AccountStore sharedStore]
                                                           queue:nil
                                                      usingBlock:^(NSNotification *aNotification){
                                                          NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                          // Do something with the error
                                                          [self checkAccounts];
                                                      }];

        [[NSNotificationCenter defaultCenter] addObserverForName:PSMAPATMO_RECEIVED_REDIRECT_URL
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *aNotification){
                                                          // Do something with the error
                                                          [[NXOAuth2AccountStore sharedStore] handleRedirectURL:[aNotification.userInfo objectForKey:@"url"]];
                                                      }];


        NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"accessToken.expiresAt" ascending:YES selector:@selector(compare:)];
        NSArray * unsortedArray = [[NXOAuth2AccountStore sharedStore] accounts];
        
        self.oAuthAccount = [[unsortedArray sortedArrayUsingDescriptors:@[sortDescriptor]] lastObject];
    }
    instance = self;
    return self;
}


#pragma mark - Account Validation
- (BOOL) hasAccount
{
    DLogFuncName();
    return (self.oAuthAccount != nil);
}


- (BOOL)accountIsValid:(NXOAuth2Account*)oAuthAccount
{
    DLogFuncName();
    return ([self.oAuthAccount.accessToken.expiresAt compare:[NSDate date]] == NSOrderedDescending);
}


- (BOOL)currentAccountIsValid
{
    DLogFuncName();
    return ([self hasAccount] && [self accountIsValid:[self account]]);
}


- (NXOAuth2Account*) account
{
    DLogFuncName();
    return self.oAuthAccount;
}


#pragma mark - Request Account
- (void) requestAccount
{
    DLogFuncName();
    if (!self.oAuthAccount)
    {
        [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:ACCOUNT_TYPE];
    }
}


- (void) requestAccountWithUser:(NSString*)user andPass:(NSString*)pass
{
    DLogFuncName();
    if (!self.oAuthAccount)
    {
        [self checkAccounts];
        [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:ACCOUNT_TYPE
                                                              username:USER_NAME
                                                              password:USER_PASS];
    }
}


- (void) requestAccountWithPreparedAuthorizationURLHandler
{
    DLogFuncName();
    if (![self currentAccountIsValid])
    {
        [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:ACCOUNT_TYPE
                                       withPreparedAuthorizationURLHandler:^(NSURL *preparedURL){

                                           [[NSNotificationCenter defaultCenter] postNotificationName:PSMAPATMO_RECEIVED_AUTH_URL object:nil userInfo:@{ @"url" : preparedURL} ];

                                       }];
    }
}


- (void) checkAccounts
{
    DLogFuncName();
    for (NXOAuth2Account * account in [[NXOAuth2AccountStore sharedStore] accounts])
    {

        // Do something with the account
        NSLog(@"Account = %@", account);
        NSDate *expireDate = account.accessToken.expiresAt;
        NSDate *now = [NSDate date];

        if ([expireDate compare:now] == NSOrderedDescending)
        {
            NSLog(@"expireDate is later than now");
            self.oAuthAccount = account;
            break;

        }
    }
}


@end