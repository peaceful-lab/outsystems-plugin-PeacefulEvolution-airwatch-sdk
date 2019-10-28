
/*
 Copyright © 2016 VMware, Inc. All rights reserved.
 This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
 AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
 */

/*! \file AWDataSamplerTypes.h */

/**
 @enum AWDataSamplerModuleBitmask       Enumeration that defines the DataSampler module type.
 @version 5.9.9.6
 */

enum {
    AWDataSamplerModuleNone            = 0,
    AWDataSamplerModuleSystem          = 1 << 0,	/** System module of DataSampler   */
    AWDataSamplerModuleAnalytics       = 1 << 1,	/** Analytics   module of DataSampler*/
    AWDataSamplerModuleGPS             = 1 << 2,	/** GPS module of DataSampler   */
    AWDataSamplerModuleNetworkData     = 1 << 3,	/** NetworkData module of DataSampler   */
    AWDataSamplerModuleCallLog         = 1 << 4,	/** Call log module of DataSampler   */
    AWDataSamplerModuleNetworkAdapter  = 1 << 5,	/** Network adapter module of DataSampler   */
    AWDataSamplerModuleWLAN2Sample     = 1 << 6,     /** WLAN2 sample module of DataSampler   */
    AWDataSamplerModuleAppSample       = 1 << 7     /** Application sample module of DataSampler   */
};

typedef NSUInteger AWDataSamplerModuleBitmask;
