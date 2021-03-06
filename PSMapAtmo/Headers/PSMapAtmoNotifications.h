//
//  PSMAPATMONotifications.h
//  PSMAPATMO
//
//  Created by Philip Schneider on 05.12.13.
//  Copyright (c) 2013 phschneider.net. All rights reserved.
//

#ifndef PSMAPATMO_PSMAPATMONotifications____FILEEXTENSION___
#define PSMAPATMO_PSMAPATMONotifications____FILEEXTENSION___

#define PSMAPATMO_API_DATA_RECEIVED   @"PSMAPATMO_API_DATA_RECEIVED"


// PUBLIC
#define PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION   @"PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION"
#define PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION_USERINFO_KEY @"PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION_USERINFO_KEY"
#define PSMAPATMO_PUBLIC_DEVICE_ADDED_NOTIFICATION      @"PSMAPATMO_PUBLIC_DEVICE_ADDED_NOTIFICATION"
#define PSMAPATMO_PUBLIC_CLEAR_STORAGE                  @"PSMAPATMO_PUBLIC_CLEAR_STORAGE"
#define PSMAPATMO_PUBLIC_CLEAR_MAP                      @"PSMAPATMO_PUBLIC_CLEAR_MAP"
#define PSMAPATMO_PUBLIC_CLEAR_ALL                      @"PSMAPATMO_PUBLIC_CLEAR_ALL"


#define PSMAPATMO_NOTIFICATIONS     @[PSMAPATMO_API_DATA_RECEIVED, PSMAPATMO_PUBLIC_MEASURES_UPDATE_NOTIFICATION, PSMAPATMO_PUBLIC_DEVICE_ADDED_NOTIFICATION]

// MAP
#define PSMAPATMO_PUBLIC_MAP_CHANGED_NOTIFICATION       @"PSMAPATMO_PUBLIC_MAP_CHANGED_NOTIFICATION"
#define PSMAPATMO_PUBLIC_MAP_UPDATED_USER_LOCATION      @"PSMAPATMO_PUBLIC_MAP_UPDATED_USER_LOCATION"
#define PSMAPATMO_API_UPDATE_FILTER                     @"PSMAPATMO_API_UPDATE_FILTER"
#define PSMAPATMO_COOKIE_UPDATED_NOTIFICICATION         @"PSMAPATMO_COOKIE_UPDATED_NOTIFICICATION"
#define PSMAPATMO_PUBLIC_FIRST_START_NOTIFICATION       @"PSMAPATMO_PUBLIC_FIRST_START_NOTIFICATION"

// ERRORS
#define PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_SERVICES_NOT_ENABLED    @"PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_SERVICES_NOT_ENABLED"
#define PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_RESTRICTED         @"PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_RESTRICTED"
#define PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_DENIED             @"PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_DENIED"
#define PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_UNKNOWN_ERROR           @"PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_UNKNOWN_ERROR"

#define PSMAPATMO_MAP_NOTIFICATIONS     @[PSMAPATMO_PUBLIC_MAP_CHANGED_NOTIFICATION, PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_UNKNOWN_ERROR, PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_DENIED, PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_SERVICES_NOT_ENABLED,PSMAPATMO_PUBLIC_MAP_ERROR_LOCATION_AUTH_RESTRICTED]



#endif
