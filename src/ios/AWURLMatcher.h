//
//  AWURLMatcher.h
//  AWCordovaPlugins
//
//  Created by VMware on 16/07/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWURLMatcher : NSObject

+ (BOOL)URLRegex:(NSString *)urlRegex matchesRequestString:(NSString *)requestString;
+ (BOOL)URLRegex:(NSString *)urlRegex matchesRequest:(NSURLRequest *)request;
+ (BOOL)request:(NSURLRequest *)request inIAAllowedSites:(NSArray*)allowedSites;

@end

NS_ASSUME_NONNULL_END
