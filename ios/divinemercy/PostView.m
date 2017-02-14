//
//  PostView.m
//  divinemercy
//
//  Created by Hao Lian on 4/22/15.
//
//

#import "UIColor+Expanded.h"

#import "PostCentaur.h"
#import "PostView.h"

@interface PostView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *parentTitleView;
@property (nonatomic, strong) UILabel *parentBodyView;

@end

@implementation PostView

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSParameterAssert(0);
    return [super initWithCoder:aDecoder];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) return nil;
    [self prepare];
    return self;
}

- (void)prepare {
    self.titleLabel = [self makeLabel];
    self.bodyLabel = [self makeBody];
    self.parentTitleView = [self makeParent];
    self.parentBodyView = [self makeParent];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bodyLabel];
    [self addSubview:self.parentTitleView];
    [self addSubview:self.parentBodyView];

    for (UIView *view in @[self.bodyLabel, self.titleLabel, self.parentTitleView, self.parentBodyView]) {
        [view autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
        [view autoAlignAxisToSuperviewAxis:ALAxisVertical];
    }

    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.bodyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:10];
    [self.parentTitleView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.bodyLabel withOffset:10];
    [self.parentBodyView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.parentTitleView withOffset:10];
    [self.parentBodyView autoPinEdgeToSuperviewEdge:ALEdgeBottom];

    RAC(self, titleLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.post.author;
    }];

    RAC(self, bodyLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.post.body;
    }];

    RAC(self, parentTitleView.text) = [[RACObserve(self, post) ignore:nil] map:^id _Nullable(PostCentaur*  _Nullable post) {
        return post.parent == nil ? @"n/a" : post.parent.author;
    }];

    RAC(self, parentBodyView.text) = [[RACObserve(self, post) ignore:nil] map:^id _Nullable(PostCentaur*  _Nullable post) {
        return post.parent == nil ? @"n/a" : post.parent.body;
    }];
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
    l.numberOfLines = 0;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    l.font = [UIFont systemFontOfSize:13];
    return l;
}

- (UILabel *)makeParent {
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectNonsense];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.numberOfLines = 0;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    l.font = [UIFont systemFontOfSize:13];
    l.textColor = [UIColor colorWithRGBHex:0xaaafaf];
    return l;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bodyLabel.preferredMaxLayoutWidth = self.bounds.size.width;
    [self.bodyLabel invalidateIntrinsicContentSize];
    self.parentTitleView.preferredMaxLayoutWidth = self.bounds.size.width;
    [self.parentTitleView invalidateIntrinsicContentSize];
    self.parentBodyView.preferredMaxLayoutWidth = self.bounds.size.width;
    [self.parentBodyView invalidateIntrinsicContentSize];
    [super layoutSubviews];
}

@end
