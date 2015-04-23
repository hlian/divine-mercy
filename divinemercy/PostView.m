//
//  PostView.m
//  divinemercy
//
//  Created by Hao Lian on 4/22/15.
//
//

#import "PostCentaur.h"
#import "PostView.h"

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
    self.titleLabel = [self makeLabel];
    self.bodyLabel = [self makeBody];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bodyLabel];

    [self.bodyLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.bodyLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];

    [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.bodyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:10];
    [self autoSetDimension:ALDimensionHeight toSize:100 relation:NSLayoutRelationEqual];

    RAC(self, titleLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.author;
    }];

    RAC(self, bodyLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.body;
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
    l.numberOfLines = -1;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    l.font = [UIFont fontWithName:@"Verdana" size:13];
    return l;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bodyLabel.preferredMaxLayoutWidth = self.bounds.size.width - 20;
}

@end
