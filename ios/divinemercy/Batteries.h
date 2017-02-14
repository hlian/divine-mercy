@interface IndexedObject<T> : NSObject <NSCopying>

@property (nonatomic, copy, nonnull) NSIndexPath *index;
@property (nonatomic, copy, nonnull) T obj;

- (nonnull instancetype)initWithIndex:(nonnull NSIndexPath *)i obj:(nonnull id)obj;

@end
