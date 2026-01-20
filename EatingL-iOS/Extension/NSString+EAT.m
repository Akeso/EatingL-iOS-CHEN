//
//  NSString+EAT.m
//  PhotoK-iOS
//
//  Created by Micheal on 2025/12/22.
//

#import "NSString+EAT.h"

@implementation NSString (EAT)

- (NSString *)eat_Localized {
    NSString *lang = NSLocalizedString(self, @"");
    if ([lang isEqualToString:self]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if (bundle) {
            return NSLocalizedStringFromTableInBundle(self, @"Localizable", bundle, @"");
        }
    }
    return lang;
}

@end
