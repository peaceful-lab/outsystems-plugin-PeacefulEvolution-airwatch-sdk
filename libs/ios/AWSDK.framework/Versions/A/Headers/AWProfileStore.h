/*
 Copyright © 2016 VMware, Inc. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */

/*! \file AWProfileStore.h */


#import <Foundation/Foundation.h>
#import "AWProfile.h"


@interface AWProfileStore:NSObject

/**
 Stores the AWProfile object in local storage.
 @return BOOL indicating whether the profile was stored successfully
*/
- (BOOL)storeProfile:(AWProfile*)profile;

/**
 Provides an array of all AWProfiles currently stored on the device.
 @return NSArray of AWProfile objects.
 */
- (NSArray*)allProfiles AW_DEPRECATED_ATTRIBUTE_MESSAGE("Use allProfiles:");

/**
 Provides an array of all SDK AWProfiles currently stored on the device.
 @return NSArray of AWProfile objects.
 */
- (NSArray*)allSDKProfiles AW_DEPRECATED_ATTRIBUTE_MESSAGE("Use allSDKProfiles:");

/**
 Provides an array of all App AWProfiles currently stored on the device.
 @return NSArray of AWProfile objects.
 */
- (NSArray*)allAppProfiles AW_DEPRECATED_ATTRIBUTE_MESSAGE("Use allAppProfiles:");

/**
 Provides an array of all AWProfiles currently stored on the device.
 @return NSArray of AWProfile objects.
 */
- (NSArray*)allProfileDictionaries AW_DEPRECATED_ATTRIBUTE_MESSAGE("Use allProfileDictionaries:");

/**
 Provides an array of all SDK AWProfiles currently stored on the device.
 @return NSArray of AWProfile objects.
 */
- (NSArray*)allSDKProfileDictionaries AW_DEPRECATED_ATTRIBUTE_MESSAGE("Use allSDKProfileDictionaries:");

/**
 Provides an array of all App AWProfiles currently stored on the device.
 @return NSArray of AWProfile objects.
 */
- (NSArray*)allAppProfileDictionaries AW_DEPRECATED_ATTRIBUTE_MESSAGE("Use allAppProfileDictionaries:");

/**
 Provides an array of all AWProfiles currently stored on the device.
 @param if an error occurs, return an error with domain AWSDKProfileErrorDomain
 and codes described in AWSDKProfileErrorCodes
 @return NSArray of AWProfile objects, nil if error occurs.

 */
- (NSArray*)allProfiles: (NSError**)error;

/**
 Provides an array of all SDK AWProfiles currently stored on the device.
 @param if an error occurs, return an error with domain AWSDKProfileErrorDomain
 and codes described in AWSDKProfileErrorCodes
 @return NSArray of AWProfile objects, nil if error occurs.
 */
- (NSArray*)allSDKProfiles: (NSError**)error;;

/**
 Provides an array of all App AWProfiles currently stored on the device.
 @param if an error occurs, return an error with domain AWSDKProfileErrorDomain
 and codes described in AWSDKProfileErrorCodes
 @return NSArray of AWProfile objects, nil if error occurs.
 */
- (NSArray*)allAppProfiles: (NSError**)error;;

/**
 Provides an array of all AWProfiles Dictionary representation currently stored on the device.
 @param if an error occurs, return an error with domain AWSDKProfileErrorDomain
 and codes described in AWSDKProfileErrorCodes
 @return NSArray of AWProfile objects, nil if error occurs.
 */
- (NSArray*)allProfileDictionaries: (NSError**)error;;

/**
 Provides an array of all SDK AWProfiles Dictionary representation currently stored on the device.
 @param if an error occurs, return an error with domain AWSDKProfileErrorDomain
 and codes described in AWSDKProfileErrorCodes
 @return NSArray of AWProfile objects, nil if error occurs.
 */
- (NSArray*)allSDKProfileDictionaries: (NSError**)error;;

/**
 Provides an array of all App AWProfile Dictionary representation currently stored on the device.
 @param if an error occurs, return an error with domain AWSDKProfileErrorDomain
 and codes described in AWSDKProfileErrorCodes
 @return NSArray of AWProfile objects, nil if error occurs.
 */
- (NSArray*)allAppProfileDictionaries: (NSError**)error;;

@end
