#import "MainVC.h"

#define kRectNonsense CGRectMake(0, 0, 100, 100)

@interface PostCentaur : NSObject

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *body;

@end

@interface PostsCentaur : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *posts;

@end

@interface PostView : UIView

@property (nonatomic, strong) PostCentaur *post;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

@end

static NSString *kAPI(NSString *s) {
    NSURLComponents *comp = [NSURLComponents componentsWithString:@"https://basilica.horse/api"];
    comp.path = [comp.path stringByAppendingPathComponent:s];
    return comp.URL.absoluteString;
}

static PostCentaur *postOfJSON(NSDictionary *dict) {
    PostCentaur *centaur = [[PostCentaur alloc] init];
    centaur.author = dict[@"user"][@"name"];
    centaur.body = dict[@"content"];
    return centaur;
}

static PostsCentaur *postsOfJSON(NSArray *array) {
    NSArray *posts = [array.rac_sequence map:^id(NSDictionary *dict) {
        return postOfJSON(dict);
    }].array;
    PostsCentaur *centaur = [[PostsCentaur alloc] init];
    centaur.posts = posts;
    return centaur;
}

static RACSignal *signalOfPosts(void) {
    AFHTTPRequestOperationManager *m = [AFHTTPRequestOperationManager manager];
    m.responseSerializer = [AFJSONResponseSerializer serializer];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [m GET:kAPI(@"/posts") parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *json) {
            [subscriber sendNext:postsOfJSON(json)];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}


@interface MainVC () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PostsCentaur *posts;

@end

@implementation MainNC
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
    self.titleLabel = [self makeLabel];
    self.bodyLabel = [self makeBody];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bodyLabel];

    [self.bodyLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-20];
    [self.bodyLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [self.titleLabel autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self withOffset:-20];
    [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];

    [self.titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.bodyLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.bodyLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.titleLabel withOffset:10];

    RAC(self, titleLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.author;
    }];

    RAC(self, bodyLabel.text) = [[RACObserve(self, post) ignore:nil] map:^id(PostCentaur *post) {
        return post.body;
    }];
}

- (UILabel *)makeLabel {
    UILabel *l = [[UILabel alloc] initWithFrame:kRectNonsense];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.numberOfLines = 1;
    l.font = [UIFont boldSystemFontOfSize:15];
    l.preferredMaxLayoutWidth = 200;
    return l;
}

- (UILabel *)makeBody {
    UILabel *l = [[UILabel alloc] initWithFrame:kRectNonsense];
    l.translatesAutoresizingMaskIntoConstraints = NO;
    l.numberOfLines = -1;
    l.lineBreakMode = NSLineBreakByWordWrapping;
    return l;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.bodyLabel.preferredMaxLayoutWidth = self.bounds.size.width - 20;
}

@end

@implementation PostCentaur
@end

@implementation PostsCentaur

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"main" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    PostView *view = [[PostView alloc] initWithFrame:kRectNonsense];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.post = self.posts[indexPath.row];
    [cell.contentView addSubview:view];
    [view autoPinEdgesToSuperviewMargins];
    return cell;
}

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Divine Mercy";
}

- (UITableView *)makeTableView {
    UITableView *t = [[UITableView alloc] initWithFrame:kRectNonsense style:UITableViewStylePlain];
    t.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    t.delegate = self;
    t.estimatedRowHeight = 100;
    t.rowHeight = UITableViewAutomaticDimension;
    [t registerClass:[UITableViewCell class] forCellReuseIdentifier:@"main"];
    return t;
}

- (void)loadView {
    @weakify(self);

    self.view = [[UIView alloc] initWithFrame:kRectNonsense];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    self.tableView = [self makeTableView];
    [self.view addSubview:self.tableView];

    RAC(self, posts) = [signalOfPosts() doNext:^(PostsCentaur *posts) {
        @strongify(self);
        self.tableView.dataSource = posts;
        [self.tableView reloadData];
    }];
}

@end
