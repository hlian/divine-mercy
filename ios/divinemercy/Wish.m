#import "Wish.h"
#import "Batteries.h"

@interface Asset()

@property (nonatomic, copy, nonnull) NSString *title;

@end

@implementation Asset

- (instancetype)initWithTitle:(nonnull NSString *)title {
    if (!(self = [super init])) return nil;
    self.title = title;
    return self;
}

@end

@interface Wish()

@property (nonatomic, strong, nonnull) NSMutableDictionary<IndexedObject<NSURL *> *, Asset *> *assetsByURL;
@property (nonatomic, strong, nonnull) RACSubject *events;
@property (nonatomic, strong, nonnull) dispatch_queue_t queue;

@end

@implementation Wish

- (instancetype)init {
    if (!(self = [super init])) return nil;
    self.assetsByURL = [[NSMutableDictionary alloc] initWithCapacity:100];
    self.assetsByURL[[[IndexedObject alloc] initWithIndex:[NSIndexPath indexPathWithIndex:0] obj:[NSURL URLWithString:@"http://google.com"]]] = [[Asset alloc] initWithTitle:@"what the fuck"];
    self.events = [RACSubject subject];
    self.queue = dispatch_queue_create("wish", NULL);
    return self;
}

- (void)wishURL:(IndexedObject<NSURL *> *)url {
    AFHTTPSessionManager *m = [AFHTTPSessionManager manager];
    m.responseSerializer = [AFHTTPResponseSerializer serializer];
    [m GET:url.obj.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString* s = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (s != nil) {
            HTMLDocument *doc = [HTMLDocument documentWithString:s];
            NSString *title = [doc firstNodeMatchingSelector:@"title"].textContent.strip;
            if (title != nil && ![title isEqualToString:@"YouTube"]) {
                self.assetsByURL[url] = [[Asset alloc] initWithTitle:title];
                NSLog(@"... %@", title);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"wishURL: error: task %@: %@", task, error);
    }];
}

@end
