#import "Batteries.h"

@implementation IndexedObject

- (instancetype)initWithIndex:(nonnull NSIndexPath *)i obj:(nonnull id)obj {
    if (!(self = [super init])) return nil;
    self.index = i;
    self.obj = obj;
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    IndexedObject *o = [self.class allocWithZone:zone];
    o.index = self.index;
    o.obj = self.obj;
    return self;
}

@end
