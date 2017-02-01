@interface Post : NSObject
@property (nonatomic, copy, nonnull) NSString *author;
@property (nonatomic, copy, nonnull) NSString *body;
@end

@interface PostCentaur : NSObject

@property (nonatomic, strong, nonnull) Post *post;
@property (nonatomic, strong, nullable) Post *parent;
@property (nonatomic, strong, nullable) RACCommand *highlightCommand;

@end
