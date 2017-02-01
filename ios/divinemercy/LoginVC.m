//
//  LoginVC.m
//  divinemercy
//
//  Created by Hao on 4/7/15.
//
//

#import "LoginVC.h"

static UIButton *buttonWithTitle(NSString *title) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}

static void imbueButtonColor(UIButton *button, UIColor *color) {
    [button setTitleColor:color forState:UIControlStateNormal];
    button.layer.borderColor = color.CGColor;
    button.layer.borderWidth = 1;
}

static RACSignal *signalOfLogin(NSString *email) {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSURLSessionTask *task =
        [manager POST:kAPI(@"/codes")
           parameters:@{@"email": email}
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [subscriber sendCompleted];
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  [subscriber sendError:error];
              }];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

@interface LoginVC () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *emailField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *goButton;

@end

@interface CodeVC : UIViewController

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UILabel *instructionsLabel;
@property (nonatomic, strong) UIButton *goButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) RACCommand *tokenCommand;
@property (nonatomic, strong) RACCommand *cancelCommand;

@end

@interface User ()

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *token;

@end

@implementation User

- (NSString *)description {
    return [NSString stringWithFormat:@"<User(email=%@, token=%@)>", self.email, self.token];
}

@end

@implementation CodeVC

- (void)loadView {
    @weakify(self);

    self.view = [[UIView alloc] initWithFrame:CGRectNonsense];
    self.view.backgroundColor = [UIColor whiteColor];

    self.instructionsLabel = [[UILabel alloc] initWithFrame:CGRectNonsense];
    self.instructionsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.instructionsLabel.text = [NSString stringWithFormat:@"copy the link basilica sent to %@", self.email];
    self.instructionsLabel.numberOfLines = 0;
    [self.view addSubview:self.instructionsLabel];

    self.goButton = buttonWithTitle(@"absorb pasteboard");
    imbueButtonColor(self.goButton, [UIColor blueColor]);
    [self.view addSubview:self.goButton];

    self.cancelButton = buttonWithTitle(@"oops, take me back");
    imbueButtonColor(self.cancelButton, [UIColor redColor]);
    [self.view addSubview:self.cancelButton];

    [self.instructionsLabel autoPinToTopLayoutGuideOfViewController:self withInset:10];
    [self.instructionsLabel autoPinEdgeToSuperviewMargin:ALEdgeLeft];
    [self.instructionsLabel autoPinEdgeToSuperviewMargin:ALEdgeRight];

    [self.goButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.instructionsLabel withOffset:10];
    [self.goButton autoPinEdgeToSuperviewMargin:ALEdgeLeft];
    [self.goButton autoPinEdgeToSuperviewMargin:ALEdgeRight];
    [self.goButton autoSetDimension:ALDimensionHeight toSize:44];

    [self.cancelButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.goButton withOffset:10];
    [self.cancelButton autoPinEdgeToSuperviewMargin:ALEdgeLeft];
    [self.cancelButton autoPinEdgeToSuperviewMargin:ALEdgeRight];
    [self.cancelButton autoSetDimension:ALDimensionHeight toSize:44];

    UIPasteboard *pb = [UIPasteboard generalPasteboard];

    self.cancelButton.rac_command = self.cancelCommand;

    RACSignal *signal = [[self.goButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        NSDictionary *params = [NSURL URLWithString:pb.string].uq_queryDictionary;
        return params[@"code"];
    }];

    [signal subscribeNext:^(NSString *code) {
        @strongify(self);
        if (code) {
            [self.tokenCommand execute:code];
        } else {
            NSString *m = [NSString stringWithFormat:@"this seems very wrong? (%@)", pb.string];
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"Nope!" message:m preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:vc animated:YES completion:nil];
        }
    }];
}

@end

@implementation LoginVC

- (void)loadView {
    @weakify(self);
    self.view = [[UIView alloc] initWithFrame:CGRectNonsense];
    self.view.backgroundColor = [UIColor whiteColor];

    self.emailField = [self makeEmailField];
    [self.view addSubview:self.emailField];

    self.goButton = buttonWithTitle(@"Go");
    imbueButtonColor(self.goButton, [UIColor blueColor]);
    [self.view addSubview:self.goButton];

    self.cancelButton = buttonWithTitle(@"Cancel");
    imbueButtonColor(self.cancelButton, [UIColor redColor]);
    [self.view addSubview:self.cancelButton];

    [self.emailField autoPinEdgeToSuperviewMargin:ALEdgeLeft];
    [self.emailField autoPinEdgeToSuperviewMargin:ALEdgeRight];
    [self.emailField autoPinToTopLayoutGuideOfViewController:self withInset:10];

    [self.goButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.emailField withOffset:10];
    [self.goButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.cancelButton withOffset:10];
    [self.goButton autoSetDimension:ALDimensionWidth toSize:100];
    [self.goButton autoSetDimension:ALDimensionHeight toSize:44];

    [self.cancelButton autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.emailField withOffset:10];
    [self.cancelButton autoPinEdgeToSuperviewMargin:ALEdgeLeft];
    [self.cancelButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.goButton];
    [self.cancelButton autoSetDimension:ALDimensionHeight toSize:44];

    RACSignal *emailReady = [self rac_signalForSelector:@selector(textFieldShouldReturn:)];
    RACSignal *goSignal = [self.goButton rac_signalForControlEvents:UIControlEventTouchUpInside];
    RACSignal *cancelSignal = [self.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside];

    [[RACSignal merge:@[emailReady, goSignal]] subscribeNext:^(id x) {
        @strongify(self);
        NSString *email = self.emailField.text.strip;
        if ([email containsString:@"@"] && [email containsString:@"."]) {
            [signalOfLogin(self.emailField.text.strip) subscribeCompleted:^{
                @strongify(self);
                CodeVC *vc = [self makeCodeViewController];
                [self presentViewController:vc animated:YES completion:nil];
            }];
        } else {
            NSString *m = [NSString stringWithFormat:@"You either have a very old email address, or you typed in something wrong (%@)", email];
            UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Nope!"
                                                                       message:m
                                                                preferredStyle:UIAlertControllerStyleAlert];
            [a addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:a animated:YES completion:nil];
        }
    }];

    [cancelSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.doneCommand execute:@YES];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.emailField becomeFirstResponder];
}

- (UITextField *)makeEmailField {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectNonsense];
    field.placeholder = @"Your email address e.g. obama@whitehouse.gov";
    field.translatesAutoresizingMaskIntoConstraints = NO;
    field.keyboardAppearance = UIKeyboardAppearanceDark;
    field.keyboardType = UIKeyboardTypeEmailAddress;
    field.returnKeyType = UIReturnKeyEmergencyCall;
    field.delegate = self;
    return field;
}

- (CodeVC *)makeCodeViewController {
    @weakify(self);
    CodeVC *vc = [[CodeVC alloc] initWithNibName:nil bundle:nil];
    vc.email = self.emailField.text.strip;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self dismissViewControllerAnimated:YES completion:^{
                [subscriber sendCompleted];
            }];
            return nil;
        }] replay];
    }];
    vc.tokenCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *token) {
        return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            User *user = [[User alloc] init];
            user.token = token;
            user.email = self.emailField.text.strip;
            [[self.userCommand execute:user] subscribeCompleted:^{
                @strongify(self);
                [[self.doneCommand execute:@YES] subscribe:subscriber];
            }];
            return nil;
        }] replay];
    }];
    return vc;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
