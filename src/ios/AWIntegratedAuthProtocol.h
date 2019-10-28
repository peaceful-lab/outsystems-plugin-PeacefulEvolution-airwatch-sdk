//
//  AWIntegratedAuthProtocol.h
//
// Copyright © 2017 VMware, Inc. All rights reserved.
// This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
// AirWatch products may be covered by one or more patents listed at http:www.vmware.com/go/patents.
//

#import <Foundation/Foundation.h>

@interface AWIntegratedAuthProtocol : NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request;
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request;

- (void)startLoading;
- (void)stopLoading;

- (id)initWithRequest:(NSURLRequest *)request
      cachedResponse:(NSCachedURLResponse *)cachedResponse
              client:(id <NSURLProtocolClient>)client;

@end
