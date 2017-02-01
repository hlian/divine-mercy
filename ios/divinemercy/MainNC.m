//
//  MainNC.m
//  divinemercy
//
//  Created by Hao on 4/7/15.
//
//

#import "MainNC.h"
#import "LoginVC.h"

@interface MainNC () <UINavigationControllerDelegate>

@end

@implementation MainNC

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (!(self = [super initWithRootViewController:rootViewController])) return nil;
    self.delegate = self;
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    @weakify(self);
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:nil action:nil];
    item.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            LoginVC *vc = [self makeLoginVC];
            [self presentViewController:vc animated:YES completion:^{
                [subscriber sendCompleted];
            }];
            return nil;
        }] replay];
    }];
    viewController.navigationItem.leftBarButtonItem = item;
}

- (LoginVC *)makeLoginVC {
    @weakify(self);
    LoginVC *vc = [[LoginVC alloc] initWithNibName:nil bundle:nil];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.userCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(User *user) {
        NSLog(@"%@", user);
        return [RACSignal empty];
    }];
    vc.doneCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[RACSignal defer:^RACSignal *{
            @strongify(self);
            [self dismissViewControllerAnimated:YES completion:nil];
            return [RACSignal empty];
        }] replay];
    }];
    return vc;
}

@end
