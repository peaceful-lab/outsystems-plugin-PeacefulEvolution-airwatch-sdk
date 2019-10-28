//
//  AWSharedDeviceConstants.h
//  AirWatch
//
//  Created by Rajiv Singh on 5/22/18.
//  Copyright © 2018 AirWatch. All rights reserved.
//

typedef NS_ENUM(NSUInteger, AWAppStatusEnrollmentStatus) {
    AWAppStatusEnrollmentStatusUnknown = 0,
    AWAppStatusEnrollmentStatusDiscovered,
    AWAppStatusEnrollmentStatusRegistered,
    AWAppStatusEnrollmentStatusEnrollmentInProgress,
    AWAppStatusEnrollmentStatusEnrolled,
    AWAppStatusEnrollmentStatusEnterpriseWipePending,
    AWAppStatusEnrollmentStatusDeviceWipePending,
    AWAppStatusEnrollmentStatusDeviceRetired,
    AWAppStatusEnrollmentStatusUnenrolled,
    AWAppStatusEnrollmentStatusStandaloneCatalog,
    AWAppStatusEnrollmentStatusDeviceBlacklisted,
    AWAppStatusEnrollmentStatusDevicePendingAgent,
    AWAppStatusEnrollmentStatusDevicePendingEnrollment,
    AWAppStatusEnrollmentStatusUnenrolledByFeedbackService,
    AWAppStatusEnrollmentStatusDeviceNotFound
};

typedef NS_ENUM(NSUInteger, AWAppStatus) {
    AWAppStatusUnknown = 0,
    AWAppStatusSupported, // Managed App OR Productivity APP
    AWAppStatusNotSupported // Unmanaged App
};

typedef NS_ENUM(NSUInteger, AWSharedDeviceStatus) {
    AWSharedDeviceStatusUnknown = 0,
    AWSharedDeviceStatusCheckedIn,
    AWSharedDeviceStatusCheckedOut,
    
    AWSharedDeviceStatusContextChanged = 1000,
    AWSharedDeviceStatusClusterContextChanged,
    AWSharedDeviceStatusRequestAnchor
};

#define AWSharedDeviceStatusErrorDomain  @"AWSharedDeviceStatusErrorDomain"
