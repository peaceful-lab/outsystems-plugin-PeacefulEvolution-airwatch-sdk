//
//  AWIntegratedAuthProtocol.m
//
// Copyright © 2017 VMware, Inc. All rights reserved.
// This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
// AirWatch products may be covered by one or more patents listed at http:www.vmware.com/go/patents.
//

#import "AWIntegratedAuthProtocol.h"

#import <AWSDK/AWController.h>
#import <AWSDK/AWEnrollmentAccount.h>
#import <AWSDK/AWProfile.h>
#import <AWSDK/AWServer.h>
#import "AWSDKBridge.h"
#import "AWURLMatcher.h"


#define kWildcard                           @"*"
#define kSchemeRegex                        @"((https?|ftps?)://)?"
#define kDomainRegex                        @"([\\.\\-0-9a-zA-Z])*"

static NSString * const AWIntegratedAuthRequest = @"AWIntegratedAuthRequest";

NSString *const kAWPluginVersion      = @"1.1";


@interface AWIntegratedAuthProtocol () <NSURLSessionDelegate, NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
{
    void (^_completionBlock)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential);
    BOOL allowedMethod;
}

@property (nonatomic, readwrite, strong) NSURLSession *session;
@property (nonatomic, readwrite, strong) NSURLResponse   *response;
@property (nonatomic, strong) NSURLAuthenticationChallenge *challenge;
@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, retain) NSMutableData *responseData;
@property(nonatomic, assign) BOOL sentCredentials;


@end

@implementation AWIntegratedAuthProtocol


-(void)dealloc
{
    _completionBlock = nil;
    if(self.session){
        [self.session invalidateAndCancel];
        self.session = nil;
    }
    _response = nil;
    _challenge = nil;
    
    self.task = nil;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL canInit = YES;
    
    if ([NSURLProtocol propertyForKey:AWIntegratedAuthRequest inRequest:request] == kAWPluginVersion)
    {
        canInit = NO;
    } else if ([[[request allHTTPHeaderFields] allKeys] containsObject:kAWSDKVersionKey])
    {
        canInit =  NO;
    } else if (![[[request URL] scheme] isEqualToString:@"http"] &&
               ![[[request URL] scheme] isEqualToString:@"https"])
    {
        canInit = NO;
    } else if (![AWIntegratedAuthProtocol useIntigratedAuth]) {
        canInit = NO;
    } else if (![AWIntegratedAuthProtocol requestIsAllowed:request]) {
        canInit = NO;
    }
    NSLog(@"Can AWPlugin handle this Integrated Auth request - %@", canInit ? @"YES" : @"NO");
    return canInit;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

-(id)initWithRequest:(NSURLRequest *)request
      cachedResponse:(NSCachedURLResponse *)cachedResponse
              client:(id <NSURLProtocolClient>)client
{
    NSMutableURLRequest *mutReq = [request mutableCopy];
    [[self class] setProperty:kAWPluginVersion forKey:AWIntegratedAuthRequest inRequest:mutReq];
    
    self = [super initWithRequest:mutReq cachedResponse:cachedResponse client:client];
    return self;
}

- (void)startLoading
{
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *newSess = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:self delegateQueue:nil];
    
    [self setSession:newSess];
    
    if (self.request.HTTPBody || self.request.HTTPBodyStream)
    {
        NSURLSessionUploadTask *uploadTask = [newSess uploadTaskWithRequest:self.request fromData:[AWIntegratedAuthProtocol httpBody:self.request]] ;
        [uploadTask resume];
        [self setTask:uploadTask];
    }
    else
    {
        NSURLSessionDataTask* dataTask = [newSess dataTaskWithRequest:self.request];
        [dataTask resume];
        [self setTask:dataTask];
    }
}

+(NSData *)httpBody:(NSURLRequest*)req {
    if (req.HTTPBodyStream) {
        NSInputStream *stream = req.HTTPBodyStream;
        NSMutableData *data = [NSMutableData data];
        [stream open];
        size_t bufferSize = 4096;
        uint8_t *buffer = malloc(bufferSize);
        if (buffer == NULL) {
            return nil;
        }
        while ([stream hasBytesAvailable]) {
            NSInteger bytesRead = [stream read:buffer maxLength:bufferSize];
            if (bytesRead > 0) {
                NSData *readData = [NSData dataWithBytes:buffer length: (NSUInteger)bytesRead];
                [data appendData:readData];
            } else if (bytesRead < 0) {
                free(buffer);
                return nil;
            }
        }
        free(buffer);
        [stream close];
        
        return data;
    }
    return [req HTTPBody];
}

- (void)stopLoading
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.challenge != nil) {
            
            NSURLAuthenticationChallenge *  challenge = self.challenge;
            self.challenge = nil;
            
            if([[self client] respondsToSelector:@selector(URLProtocol:didCancelAuthenticationChallenge:)]) {
                [[self client] URLProtocol:self didCancelAuthenticationChallenge:challenge];
            }
        }
    }];
    
    if(self.task != nil) {
        [self.task cancel];
        self.task = nil;
    }
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler{
    
    [self setChallenge:challenge];
    [self setTask:task];
    _completionBlock = [completionHandler copy];
    [self handleChallenge];
}


- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler{
    
    
    [self setChallenge:challenge];
    _completionBlock = [completionHandler copy];
    [self handleChallenge];
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSMutableURLRequest *newRequest = [[NSMutableURLRequest alloc]
                                       initWithURL:request.URL
                                       cachePolicy:request.cachePolicy
                                       timeoutInterval:request.timeoutInterval];
    
    [newRequest setHTTPMethod:request.HTTPMethod];
    if (request.HTTPBody) {
        [newRequest setHTTPBody:request.HTTPBody];
    } else if (request.HTTPBodyStream) {
        [newRequest setHTTPBodyStream:request.HTTPBodyStream];
    }
    
    if (response) {
        [[self class] setProperty:@"" forKey:AWIntegratedAuthRequest inRequest:newRequest];
        
        [[self client] URLProtocol:self
            wasRedirectedToRequest:newRequest
                  redirectResponse:response];
        
        completionHandler(nil);
    } else {
        completionHandler(newRequest);
    }
}


-(void)handleChallenge
{
    NSString* authenticationMethod = [[self.challenge protectionSpace] authenticationMethod];
    NSLog(@"Authentication Method %@", authenticationMethod);
    BOOL success = NO;
    NSError *error;
    
    if([NSURLAuthenticationMethodClientCertificate isEqualToString: authenticationMethod] &&
       [[AWController clientInstance] canHandleProtectionSpace:self.challenge.protectionSpace withError:&error])
    {
        success = [[AWController clientInstance] handleChallengeForURLSessionChallenge:self.challenge completionHandler:_completionBlock];
    }
    
    NSLog(@"Success:%d - Error: %@ for request: [%@]", success, error, self.request.URL.absoluteString);
    if(!success) {
        [self handleChallenge:self.challenge forRequest:self.task.originalRequest];
    }
}


/**
 NTLM/Basic/Default
 Case0: Try with enrollment creds if available, else show username/password screen.
 Case1: Try with enrollment creds(without domain), if username did not have domain,  show username/password screen.
 Case2: If creds were sent in Case1 and Case2,  show username/password screen, else if new creds was tried in case 1,
        send username without domain.
 Case3: If username screen was shown in Case2, send creds without domain.
 */

- (void)handleChallenge:(NSURLAuthenticationChallenge *)challenge
             forRequest:(NSURLRequest *)request
{
    if([NSURLAuthenticationMethodServerTrust isEqualToString: [[self.challenge protectionSpace] authenticationMethod]]){
        
        NSLog(@"Handling ServerTrust challenge");
        SecTrustRef trustRef = challenge.protectionSpace.serverTrust;
        SecTrustResultType trust_result = kSecTrustResultInvalid;
        
        if (trustRef) {
            SecTrustEvaluate(trustRef, &trust_result);
            NSLog(@"kSecTrustResult %u", trust_result);
        }
        
        if( kSecTrustResultProceed == trust_result || kSecTrustResultUnspecified == trust_result || kSecTrustResultRecoverableTrustFailure == trust_result) {
            NSURLCredential *serverTrustCredential = [NSURLCredential credentialForTrust:trustRef];
            if(serverTrustCredential)  {
                NSLog(@"calling challenge completion block for server trust");
                _completionBlock(NSURLSessionAuthChallengeUseCredential, serverTrustCredential);
                return;
            }else{
                NSLog(@"Unable to complete serverTrust");
            }
        }
        else{
            NSLog(@"Do default handling");
            _completionBlock(NSURLSessionAuthChallengePerformDefaultHandling, [NSURLCredential credentialForTrust:trustRef]);
            return;
        }
    }
    else if([NSURLAuthenticationMethodNegotiate isEqualToString: [[self.challenge protectionSpace] authenticationMethod]]){
        NSLog(@"Handling Negotiate challenge");
        return _completionBlock(NSURLSessionAuthChallengeUseCredential, nil);
    }
    
    if ([AWIntegratedAuthProtocol useIntigratedAuth]  && [AWIntegratedAuthProtocol requestIsAllowed:request]
        && [self canHandleProtectionSpace:[challenge protectionSpace]]) {
        
        switch (challenge.previousFailureCount){
                
            case 0:{
                BOOL sentChallengeResponse = [self useStoredCredsForChallenge:challenge withOutDomain:NO];
                // In case we don't have un/pwd, get credentials from anchor app.
                if(!sentChallengeResponse){
                    [self sendUpdatedCredentialsForChallenge:challenge];
                }
            }
                break;
            case 1:{
                // We tried with first set of credentials, incase that fails due to domain in username, then try without domain.
                BOOL sentChallengeResponse = [self useStoredCredsForChallenge:challenge withOutDomain:YES];
                _sentCredentials = NO;
                if(!sentChallengeResponse){
                    // if the username we tried did not have domain, then we need to get new creds from Anchor app.
                    [self sendUpdatedCredentialsForChallenge:challenge];
                }
                break;
            }
                
            case 2:{
                BOOL sentChallengeResponse = NO;
                if(_sentCredentials){
                    sentChallengeResponse = [self useStoredCredsForChallenge:challenge withOutDomain:YES];
                    _sentCredentials = NO;
                }
                if(!sentChallengeResponse){
                    //We tried to validate with domain\username and username, both fail, get new creds from Anchor app
                    [self sendUpdatedCredentialsForChallenge:challenge];
                }
                break;
            }
            case 3:{
                // if the creds in case 2 failed due to domain part try without domain
                BOOL sentChallengeResponse = [self useStoredCredsForChallenge:challenge withOutDomain:YES];
                
                if(!sentChallengeResponse){
                    NSLog(@"All cases tried");
                    [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
                }
                break;
            }
            default:
                NSLog(@"default case failure count - %ld",(long)challenge.previousFailureCount);
                [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
        }
        
    }else{
        NSLog(@"Unable to updateUserCredentialsWithCompletion failure 4");
        [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
    }
}


-(void) sendUpdatedCredentialsForChallenge:(NSURLAuthenticationChallenge *)challenge {
    [[AWController clientInstance] updateUserCredentialsWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            _sentCredentials = YES;
            NSLog(@"success in receiving new credentials");
            BOOL sentChallengeResponse = [self useStoredCredsForChallenge:challenge withOutDomain:NO];
            if(!sentChallengeResponse){
                NSLog(@" No Credentials to send - default");
                [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
            }
        } else {
            NSLog(@"defaultError updating credentials - %@", error);
            [self.client URLProtocol:self didReceiveAuthenticationChallenge:challenge];
        }
    }];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    if (self.responseData) {
        [self.responseData appendData:data];
    } else {
        self.responseData = [data mutableCopy];
    }
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (httpResponse.statusCode == 304)
    {
        /*
         Putting null check since we may not be the ones that put the cache headers on the
         request, and therefore wouldn't have have a valid response.
         */
        if (self.cachedResponse)
        {
            [[self client] URLProtocol:self cachedResponseIsValid:self.cachedResponse];
        }
    }
    
    [self.client URLProtocol:self
          didReceiveResponse:response
          cacheStoragePolicy:NSURLCacheStorageAllowed];
    
    [self setResponse:response];
    
    completionHandler(NSURLSessionResponseAllow);
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)[task response];
    NSLog(@"URL response: %@",response);
    
    if(!error){
        [self.client URLProtocolDidFinishLoading:self];
    }else{
        [self.client URLProtocol:self didFailWithError:error];
        self.responseData = nil;
        self.response = nil;
    }
}


- (BOOL)useStoredCredsForChallenge:(NSURLAuthenticationChallenge *)challenge withOutDomain: (BOOL)withOutDomain
{
    AWEnrollmentAccount *enrollmentAccount = [[AWController clientInstance] account];
    
    if (enrollmentAccount && enrollmentAccount.username.length && enrollmentAccount.password.length) {
        NSString *username = enrollmentAccount.username;
        
        if (withOutDomain) {
            NSArray *userNameParts = [enrollmentAccount.username componentsSeparatedByString:@"\\"];
            if (userNameParts.count == 2) {
                username = userNameParts[1];
            }
            else{
                return NO;
            }
        }
        BOOL isPasswordNilOrEmpty = !(enrollmentAccount.password && enrollmentAccount.password.length);
        NSLog(@"username - %lu, password - %@ ",(unsigned long)username.length, isPasswordNilOrEmpty ? @"empty" : @"present");
        
        
        
        NSURLCredential *credentials = [NSURLCredential credentialWithUser:username password:enrollmentAccount.password persistence:NSURLCredentialPersistenceForSession];
        
        _completionBlock(NSURLSessionAuthChallengeUseCredential, credentials);
        return YES;
    }
    
    BOOL isPasswordNilOrEmpty = !(challenge.proposedCredential.password && challenge.proposedCredential.password.length);
    NSLog(@"proposedCredential username - %lu, password - %@ ",(unsigned long)challenge.proposedCredential.user.length, isPasswordNilOrEmpty ? @"empty" : @"present");
    if(challenge.proposedCredential){
        _completionBlock(NSURLSessionAuthChallengeUseCredential, challenge.proposedCredential);
        return YES;
    }
    return NO;
}


- (BOOL)canHandleProtectionSpace:(NSURLProtectionSpace*)protectionSpace {
    
    NSString *authenticationMethod = [protectionSpace authenticationMethod];
    
    BOOL handleProtectionSpace = NO;
    
    handleProtectionSpace = (authenticationMethod == NSURLAuthenticationMethodNTLM
                             || authenticationMethod == NSURLAuthenticationMethodHTTPBasic
                             || authenticationMethod == NSURLAuthenticationMethodDefault);
    
    
    return handleProtectionSpace;
}


+ (BOOL)useIntigratedAuth
{
    return [[AWSDKBridge sharedInstance] enableIntegratedAuthentication];
}


+ (BOOL)requestIsAllowed:(NSURLRequest *)request
{
    NSArray *allowedDomains = [[AWSDKBridge sharedInstance] allowedSitesForIA];
    BOOL retVal = NO;
    retVal = [AWURLMatcher request:request inIAAllowedSites:allowedDomains];
    return retVal;
}

@end

