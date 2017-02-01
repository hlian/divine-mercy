@class PostCentaur;

@interface PostView : UIView

@property (nonatomic, strong) PostCentaur *post;
@property (nonatomic, strong) RACSignal *highlightedSignal;

@end
