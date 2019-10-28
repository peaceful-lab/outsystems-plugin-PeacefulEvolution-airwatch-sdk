//
//  AWActivityViewController.m
//  AWCordovaPlugins
//
//  Created by Mohammed Lazim on 4/14/17.
//
// Copyright © 2017 VMware, Inc. All rights reserved.
// This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
// AirWatch products may be covered by one or more patents listed at http:www.vmware.com/go/patents.
//

#import "AWActivityViewController.h"
#import "AWSDKBridge.h"

@interface UIActivityViewController (Private)

- (BOOL)_shouldExcludeActivityType:(UIActivity*)activity;

@end

@implementation AWActivityViewController

- (BOOL)_shouldExcludeActivityType:(UIActivity *)activity {
    
    AWSDKBridge *bridge = [AWSDKBridge sharedInstance];
    
    if([bridge restrictDocumentToApps]){
        BOOL shouldExclude = [super _shouldExcludeActivityType: activity];
        NSArray *allowedApplications = [bridge allowedApplications];
        if(!shouldExclude){
            shouldExclude = YES;
            
            if(allowedApplications){
                NSString *activityType = [activity activityType];
                
                for (NSString *application in allowedApplications) {
                    NSString *openPrefix = @"com.apple.UIKit.activity.Open.Copy."; // For third party applications, apple adds this prefix to the bundle ID while passing as UIActivity object
                    NSString *applicationBundleId = [activityType stringByReplacingOccurrencesOfString:openPrefix withString:@""];
                    if([applicationBundleId isEqualToString:application]){
                        NSLog(@"Application with bundle id %@ is whitelisted", applicationBundleId);
                        shouldExclude = NO;
                        break;
                    }
                }
            }
        }
        return shouldExclude;
    }
    else{
        return [super _shouldExcludeActivityType: activity];
    }
}

@end
