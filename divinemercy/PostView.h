@class PostCentaur;

@interface PostView : UIView

@property (nonatomic, strong) PostCentaur *post;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

@end