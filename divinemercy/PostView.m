//
//  PostView.m
//  divinemercy
//
//  Created by Hao Lian on 4/22/15.
//
//

#import "PostCentaur.h"
#import "PostView.h"

@interface PostView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UIView *actionView;


@end

@implementation PostView

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSParameterAssert(0);
    return nil;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    [self prepare];
    return self;
}

- (void)prepare {
    @weakify(self);

    self.titleLabel = [self makeLabel];
    self.bodyLabel = [self makeBody];
    self.actionView = [self makeActionView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bodyLabel];
    [self addSubview:self.actionView];

    for (UIView *view in @[self.bodyLabel, self.titleLabel, self.actionView]) {
        [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
        [view autoAlignAxisToSuperviewAxis:ALAxisVertical];
    }

    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.bodyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:10];
    [self.bodyLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.actionView];
    [self.actionView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];

    RAC(self, titleLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.author;
    }];

    RAC(self, bodyLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.body;
    }];

    [[[RACObserve(self, highlightedSignal) switchToLatest] ignore:@NO] subscribeNext:^(id value) {
        @strongify(self);
        [ALView autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
            NSLayoutConstraint *constraint =
                [self.actionView autoSetDimension:ALDimensionHeight toSize:self.actionHeight relation:NSLayoutRelationEqual];
            [self layoutIfNeeded];
            [[[[self.highlightedSignal takeUntil:self.rac_willDeallocSignal] ignore:@YES] take:1] subscribeNext:^(id x) {
                @strongify(self);
                [constraint autoRemove];
                [self layoutIfNeeded];
            }];
        }];
    }];
}

- (CGFloat)actionHeight {
    return 44;
}

- (UILabel *)makeLabel {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectNonsense];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.numberOfLines = 1;
    l.font = [UIFont boldSystemFontOfSize:15];
    l.preferredMaxLayoutWidth = 200;

    return l;
}

- (UILabel *)makeBody {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectNonsense];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.numberOfLines = -1;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    l.font = [UIFont fontWithName:@"Verdana" size:13];
    return l;
}

- (UIView *)makeActionView {
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.clipsToBounds = YES;

    UILabel *reply = [[UILabel alloc] initWithFrame:CGRectZero];
    reply.translatesAutoresizingMaskIntoConstraints = NO;
    reply.text = @"[reply]";
    reply.font = [UIFont fontWithName:@"Verdana" size:13];
    reply.textColor = [UIColor purpleColor];
    [v addSubview:reply];

    UILabel *fave = [[UILabel alloc] initWithFrame:CGRectZero];
    fave.translatesAutoresizingMaskIntoConstraints = NO;
    fave.text = @"[favorite]";
    fave.font = [UIFont fontWithName:@"Verdana" size:13];
    fave.textColor = [UIColor purpleColor];
    [v addSubview:fave];


    [reply autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [reply autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [fave autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
    [fave autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:reply withOffset:10];

    return v;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bodyLabel.preferredMaxLayoutWidth = self.bounds.size.width - 20;
    [self.bodyLabel invalidateIntrinsicContentSize];
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer {
    [[self signalUponPanning:recognizer] subscribeCompleted:^{}];
}

- (RACSignal *)signalUponPanning:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        velocity.x = 0;
        NSLog(@"panning endede: %@ %@", NSStringFromCGPoint(velocity), NSStringFromCGPoint(point));
        return [self.dragEndedVelocityCommand execute:[NSValue valueWithCGPoint:velocity]];
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"panning began");
        return [self.dragBeganCommand execute:@YES];
    } else {
        return [RACSignal empty];
    }
}

@end
