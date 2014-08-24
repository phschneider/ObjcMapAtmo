//
//  PSNetAtmoDateFormatter.m
//  PSNetAtmo
//
//  Created by Philip Schneider on 14.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#import "PSMapAtmoDateFormatter.h"

@interface PSMapAtmoDateFormatter()
@property (nonatomic, strong) NSDateFormatter * importDateFormatter;
@property (nonatomic, strong) NSDateFormatter * outputDateFormatter;
@end

@implementation PSMapAtmoDateFormatter

+ (PSMapAtmoDateFormatter *)sharedInstance
{
    DLogFuncName();
    static PSMapAtmoDateFormatter *sharedInstance;
    
    if (sharedInstance == nil) {
        sharedInstance = [[PSMapAtmoDateFormatter alloc] init];
    }
    
    return sharedInstance;
}


- (id) init
{
    DLogFuncName();
    self = [super init];
    if (self)
    {
        self.importDateFormatter = [[NSDateFormatter alloc] init];
        [self.importDateFormatter setLocale: [[NSLocale alloc] initWithLocaleIdentifier:@"de_DE"]];
        [self.importDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        self.outputDateFormatter = [[NSDateFormatter alloc] init];
        [self.outputDateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [self.outputDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return self;
}


- (NSDate*) dateFromString:(NSString*) string
{
    DLogFuncName();
    return [self.importDateFormatter dateFromString:string];
}


- (NSString*) stringFromDate:(NSDate*) date
{
    DLogFuncName();
    [self.outputDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [self.outputDateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    return [self.outputDateFormatter stringFromDate:date];
}


- (NSString*) shortStringFromDate:(NSDate*) date
{
    DLogFuncName();
    [self.outputDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [self.outputDateFormatter setDateStyle:NSDateFormatterShortStyle];
    return [self.outputDateFormatter stringFromDate:date];
}
@end
