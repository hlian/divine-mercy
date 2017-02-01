//
//  MainCell.m
//  divinemercy
//
//  Created by Hao Lian on 5/2/15.
//
//

#import "MainCell.h"

@implementation MainCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    [self prepare];
    return self;
}

- (void)prepare {
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;
    self.contentView.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10);
    self.preservesSuperviewLayoutMargins = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    UIGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self addGestureRecognizer:recognizer];
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:self.superview];
    self.contentView.frame = CGRectMake(point.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self];
        velocity.x = 0;
        NSLog(@"panning endede: %@ %@", NSStringFromCGPoint(velocity), NSStringFromCGPoint(point));
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"panning began");
    } else {
        //
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
