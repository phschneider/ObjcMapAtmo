//
//  PSNetAtmo.h
//  PSNetAtmo
//
//  Created by Philip Schneider on 23.11.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#ifndef PSNetAtmo_PSNetAtmo_h
#define PSNetAtmo_PSNetAtmo_h


#define CLIENT_ID       @"528755651b77593b2a8b4573"
#define CLIENT_SECRET   @"tDraccNdc0XCum5QCFhoFPDugKW8"
#define REQUEST_TOKEN   @"http://api.netatmo.net/oauth2/token"
#define AUTH_URL        @"http://api.netatmo.net/oauth2/authorize"
#define ACCOUNT_TYPE    @"GeekTool"

#define USER_NAME       @"info@philip-schneider.com"
#define USER_PASS       @"7qUQVRLdPffg6p"

#define DEFAULTS_APP_FIRST_START_DATE        @"DEFAULTS_APP_FIRST_START_DATE"
#define DEFAULS_APP_VERSION_HISTORY          @"DEFAULS_APP_VERSION_HISTORY"

#define DEFAULTS_APP_PREVIOUS_VERSION         @"DEFAULTS_APP_PREVIOUS_VERSION"
#define DEFAULTS_APP_PREVIOUS_VERSION_DATE    @"DEFAULTS_APP_PREVIOUS_VERSION_DATE"

#define DEFAULTS_APP_CURRENT_VERSION         @"DEFAULTS_APP_CURRENT_VERSION"
#define DEFAULTS_APP_CURRENT_VERSION_DATE    @"DEFAULTS_APP_CURRENT_VERSION_DATE"


#define NETATMO_URL_USER            @"http://api.netatmo.net/api/getuser"
#define NETATMO_URL_DEVICE_LIST     @"http://api.netatmo.net/api/devicelist"
#define NETATMO_URL_DEVICE_MEASSURE @"http://api.netatmo.net/api/getmeasure"

#define NETATMO_ENTITY_DEVICE_PLACE     @"PSNetAtmoDevicePlace"
#define NETATMO_ENTITY_DEVICE           @"PSNetAtmoDevice"
#define NETATMO_ENTITY_PRIVATE_DEVICE   @"PSNetAtmoPrivateDevice"
#define NETATMO_ENTITY_PUBLIC_DEVICE    @"PSNetAtmoPublicDevice"
#define NETATMO_ENTITY_MODULE           @"PSNetAtmoModule"

#import <NXOAuth2Client/NXOAuth2.h>

#import "PSMapAtmoApi.h"

#import "PSMapAtmoAccount.h"

#endif
