//
//  NSString+Helper.h
//  AWCordovaPlugins
//
//  Created by VMWare on 16/07/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Helper)


- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)set;

@end

NS_ASSUME_NONNULL_END
