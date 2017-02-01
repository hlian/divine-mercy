@interface PostCentaur : NSObject

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) RACCommand *highlightCommand;

@end