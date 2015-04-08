//
//  LoginVC.h
//  divinemercy
//
//  Created by Hao on 4/7/15.
//
//

#import <UIKit/UIKit.h>

@interface User : NSObject

@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *token;

@end

@interface LoginVC : UIViewController

@property (nonatomic, strong) RACCommand *userCommand;
@property (nonatomic, strong) RACCommand *doneCommand;

@end
