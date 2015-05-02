@class PostCentaur;

@interface PostView : UIView

@property (nonatomic, strong) PostCentaur *post;
@property (nonatomic, strong) RACSignal *highlightedSignal;

@property (nonatomic, strong) RACCommand *dragEndedVelocityCommand;
@property (nonatomic, strong) RACCommand *dragBeganCommand;

@property (nonatomic, readonly) CGFloat actionHeight;

@end