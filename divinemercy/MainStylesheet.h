//
//  MainStylesheet.h
//  divinemercy
//
//  Created by Hao Lian on 5/2/15.
//
//

#import <Foundation/Foundation.h>

@interface MainStylesheet : NSObject

@property (nonatomic, readonly) UIColor *frontColor;
@property (nonatomic, readonly) UIColor *backColor;

DECLARE_SINGLETON_FOR_CLASS(MainStylesheet)

@end
