//
//  NSString+Helper.m
//  AWCordovaPlugins
//
//  Created by VMWare on 16/07/19.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)set {
    NSRange rangeOfLaststWantedCharacter = [self rangeOfCharacterFromSet:[set invertedSet] options:NSBackwardsSearch];
    if (rangeOfLaststWantedCharacter.location == NSNotFound) {
        return @"";
    }
    return [self substringToIndex:(rangeOfLaststWantedCharacter.location +1)];
}

@end
