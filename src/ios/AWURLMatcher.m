//
//  AWURLMatcher.m
//  AWCordovaPlugins
//
//  Created by VMware on 16/07/19.
//

#import "AWURLMatcher.h"
#import "NSString+Helper.h"

static NSString *const EMPTY_STRING                        =      @"";

static NSString *const kRegexStart                         =      @"^";
static NSString *const kRegexEnd                           =      @"$";
static NSString *const kWildcard                           =      @"*";

static NSString *const kSchemeRegex                        =      @"((https?|ftps?)://)?";
static NSString *const kWwwRegex                           =      @"(www.)?";
static NSString *const kDomainRegex                        =      @"([\\.\\-a-zA-Z0-9])*";
static NSString *const kPathRegex                          =      @"([\\/\\.\\-a-zA-Z0-9])*";
static NSString *const kPortRegex                          =      @"(:[0-9]+)?";

static NSString *const kIPValueRegex                       =      @"[0-9]{1,3}";
static NSString *const kIPAddressRegex                     =      @"^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$";

static NSCharacterSet* trailingSlashSet;

@implementation AWURLMatcher

+ (void)load {
    trailingSlashSet = [NSCharacterSet characterSetWithCharactersInString:@"/"];
}

/*
 Processes User Entered URL request by removing query and fragment params
 */
+ (BOOL)URLRegex:(NSString *)urlRegex matchesRequest:(NSURLRequest *)request
{
    NSString *userEnteredURLString = request.URL.absoluteString;
    
    if (userEnteredURLString.length == 0 || request.URL.host.length == 0) {
        return NO;
    }
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:userEnteredURLString];
    
    // Remove query parameters and fragments from user entered URL's path
    components.query = nil;
    components.fragment = nil;
    components.scheme = components.scheme.lowercaseString;
    components.host = components.host.lowercaseString;
    userEnteredURLString = components.string;
    
    // Remove "/" if it is the last character in domain or path
    userEnteredURLString = [userEnteredURLString stringByTrimmingTrailingCharactersInSet:trailingSlashSet];
    
    return [AWURLMatcher URLRegex:urlRegex matchesRequestString:userEnteredURLString];
}

/* Gets a valid regEx for console setting's URL
 * Checks with user entered URL to find a match
 */
+ (BOOL)URLRegex:(NSString *)urlRegex matchesRequestString:(NSString *)requestString
{
    NSError *error = nil;
    NSString *preprocessedURL = urlRegex;
    BOOL shouldAppendEOL = NO;
    
    // End Of Line will be appended to the Regex only if console URL ends with wildcard
    shouldAppendEOL = ([urlRegex hasSuffix:kWildcard])?NO:YES;
    
    preprocessedURL = [AWURLMatcher validRegExForConsoleURL:preprocessedURL userEntered:requestString shouldAppendEOL:&shouldAppendEOL];
    // Escape reserved characters in regex like '.'
    preprocessedURL = [preprocessedURL stringByReplacingOccurrencesOfString:@"." withString:@"\\."];
    
    if (!preprocessedURL) {
        // Domains did not match
        return NO;
    }
    
    // Add start and end regex markers
    preprocessedURL = [kRegexStart stringByAppendingString:preprocessedURL];
    
    if (shouldAppendEOL) {
        //Add End Of Line to regex
        preprocessedURL = [preprocessedURL stringByAppendingString:kRegexEnd];
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:preprocessedURL
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSUInteger matches = [regex numberOfMatchesInString:requestString
                                                options:NSMatchingReportProgress
                                                  range:NSMakeRange(0, requestString.length)];
    return matches > 0;
}

/* Creates scheme, domain and path components from console received URL.
 * Returns a regEx for console setting's URL
 */
+ (NSString *)validRegExForConsoleURL:(NSString *)regex userEntered:(NSString *)requestString shouldAppendEOL:(BOOL *)shouldAppendEOL{
    
    NSString *regexWithPath = regex;
    NSString *scheme;
    NSString *domain;
    NSString *path;
    
    NSScanner *scanner = [NSScanner scannerWithString:regex];
    // Get Scheme
    if ([regex containsString:@"://"]) {
        [scanner scanUpToString:@"://" intoString:&scheme];
        [scanner scanString:@"://" intoString:nil];
    }
    
    // Get Domain
    [scanner scanUpToString: @"/" intoString:&domain];
    [scanner scanString: @"/" intoString:nil];
    
    if (!scanner.isAtEnd){
        // Get Path
        path = [scanner.string substringFromIndex:scanner.scanLocation];
        // Remove query parameters from path
        if ([path containsString:@"?"]) {
            [scanner scanUpToString:@"?" intoString:&path];
            [scanner scanString:@"?" intoString:nil];
        }
        
        // Remove fragments from path
        if ([path containsString:@"#"]) {
            [scanner scanUpToString:@"#" intoString:&path];
            [scanner scanString:@"#" intoString:nil];
        }
        
        // Remove "/" if its the last character
        path = [path stringByTrimmingTrailingCharactersInSet:trailingSlashSet];
        
        // If path is other than wildcard character, prefix it with '/'
        if (path && ![path isEqualToString:kWildcard]) {
            path = [@"/" stringByAppendingString:path];
        }
        path = [path stringByReplacingOccurrencesOfString:kWildcard withString:kPathRegex];
        
    } else {
        // RegexPath will be domain.
        if (![regexWithPath hasSuffix:@"/"]) {
            // Domain without a "/", so regex should match if anything comes appended to domain
            *shouldAppendEOL = NO;
        }else {
            // URL is domain suffixed with / . It will be considered a path.
            // dont prefix www.
            path = EMPTY_STRING;
        }
    }
    
    // Get scheme and domain if domain is with port
    [AWURLMatcher domainWithPort:&domain scheme:&scheme];
    
    // Replace wild card by alphabets or number or . or ? or -
    domain = [domain stringByReplacingOccurrencesOfString:kWildcard withString:kDomainRegex];
    
    // Get regEx with scheme, domain and path.
    regexWithPath = [AWURLMatcher regexWithScheme:scheme domain:domain path:path requestString:requestString];
    
    return regexWithPath;
}

/* Constructs a RegEx with scheme, domain and path components
 * Prefixes with scheme or www. if not already
 */
+ (NSString *)regexWithScheme:(NSString *)scheme domain:(NSString *)domain path:(NSString *)path requestString:(NSString *)requestString{
    
    NSString *regex;
    // Create Regex for Console URL
    NSString *domainRegex = domain;
    NSString *schemeRegex;
    
    schemeRegex = (scheme) ? scheme : @"(https?|ftps?)?";
    
    // We prefix "www." only if its just domain and not for path
    if(domain && ![domain hasPrefix:@"www."] && !path)
    {
        domainRegex = [kWwwRegex stringByAppendingString:domain];
    }
    
    //Check if console and user entered url has the same domain.
    BOOL domainsMatch = [AWURLMatcher consoleURLDomain:domainRegex matchesUserEnteredURLDomain:requestString];
    if (!domainsMatch) {
        return nil;
    }
    
    regex = [NSString stringWithFormat:@"%@://%@",[schemeRegex lowercaseString],[domainRegex lowercaseString]];
    // if console url has just domain then path will be nil
    if (path && path.length) {
        // prefix with '/' if it is not already
        if (![path hasPrefix:@"/"] && ![path containsString:@"*"]) {
            path = [@"/" stringByAppendingString:path];
        }
        regex = [regex stringByAppendingFormat:@"%@",path];
    }
    
    return regex;
}

/* Compares the domain parts coming from console settings and user entered URL.
 * Does strict matching by adding ^ & $ to the console domain
 */
+ (BOOL)consoleURLDomain:(NSString *)domainRegex matchesUserEnteredURLDomain:(NSString *)requestString {
    
    if (!domainRegex) {
        NSLog(@"Domain is Nil in Console payload URL.");
        return NO;
    }
    
    NSUInteger matches = 0;
    domainRegex = [kRegexStart stringByAppendingString:domainRegex];
    
    if (![domainRegex hasSuffix:kWildcard]) {
        domainRegex = [domainRegex stringByAppendingString:kRegexEnd];
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:domainRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    if (requestString) {
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:requestString];
        NSString *userEnteredURLDomain = components.host;
        if (components.port) {
            userEnteredURLDomain = [NSString stringWithFormat:@"%@:%@",components.host,components.port];
        }
        
        if (userEnteredURLDomain) {
            matches = [regex numberOfMatchesInString:userEnteredURLDomain
                                             options:NSMatchingReportProgress
                                               range:NSMakeRange(0, userEnteredURLDomain.length)];
        }
    }
    return matches > 0;
}

+ (void)domainWithPort:(NSString *__autoreleasing *)domain scheme:(NSString *__autoreleasing *)scheme{
    
    // Replace wildcard for port by (:[0-9]+)?
    if ([*domain containsString:@":*"]) {
        *domain = [*domain stringByReplacingOccurrencesOfString:@":*" withString:kPortRegex];
    }
    
    // Provide http(s) depending on standard port
    if ([*domain hasSuffix:@":80"] || [*domain hasSuffix:@":443"]) {
        
        NSUInteger location = [*domain rangeOfString:@":"].location;
        *domain = [*domain substringToIndex:location];
        *scheme = @"(https?)?";
    }
}


+(BOOL)request:(NSURLRequest *)request inIAAllowedSites:(NSArray*)allowedSites
{
    for (NSString *domain in allowedSites) {
        if ([domain stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
            if ([AWURLMatcher URLRegex:domain matchesRequest:request]) {
                return YES;
            }
        }
    }
    return NO;
}

@end

