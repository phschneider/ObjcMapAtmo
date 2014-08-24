//
// Created by Philip Schneider on 05.12.13.
// Copyright (c) 2013 phschneider.net. All rights reserved.
//


#import "PSMapAtmoError.h"


@implementation PSMapAtmoError {

}

- (NSString*)errorMessageForCode:(int)code
{
    DLogFuncName();
    switch (code)
    {
        case 1:
            return @"No access token given to the API";
            break;
        case 2:
            return @"The access token is not valid";
            break;
        case 3:
            return @"The access token has expired";
            break;
        case 4:
            return @"Internal error";
            break;
        case 5:
            return @"The application has been deactivated";
            break;
        case 9:
            return @"The device has not been found";
            break;
        case 10:
            return @"A mandatory API parameter is missing";
            break;
        case 11:
            return @" An unexpected error occured";
            break;
        case 13:
            return @"Operation not allowed";
            break;
        case 15:
            return @" Installation of the device has not been finalized";
            break;
        case 21:
            return @"Invalid argument";
            break;
        case 25:
            return @"Invalid date given";
            break;
        case 26:
            return @"Maximum usage of the API has been reached by application";
            break;
    }
    return nil;
}



@end