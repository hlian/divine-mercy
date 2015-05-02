//
//  MainStylesheet.m
//  divinemercy
//
//  Created by Hao Lian on 5/2/15.
//
//

#import "MainStylesheet.h"

@implementation MainStylesheet

SYNTHESIZE_SINGLETON_FOR_CLASS(MainStylesheet)

- (UIColor *)frontColor {
    return [UIColor colorWithRGBHex:0xf3f6d7];
}

- (UIColor *)backColor {
    return [UIColor colorWithRGBHex:0x394047];
}

@end
