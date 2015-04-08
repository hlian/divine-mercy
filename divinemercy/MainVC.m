#import "MainVC.h"
#import "LoginVC.h"

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

@implementation PostCentaur
@end

@implementation PostsCentaur

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"main" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.contentView.layoutMargins = UIEdgeInsetsMake(10, 5, 10, 5);
    cell.preservesSuperviewLayoutMargins = NO;

    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    PostView *view = [[PostView alloc] initWithFrame:CGRectNonsense];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.post = self.posts[indexPath.row];
    [cell.contentView addSubview:view];
    [view autoPinEdgesToSuperviewMargins];
    return cell;
}

@end

@implementation MainVC

- (void)viewDidLoad {
    @weakify(self);
    [super viewDidLoad];
    self.title = @"Divine Mercy";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:nil action:nil];
    self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        LoginVC *vc = [[LoginVC alloc] initWithCoder:nil];
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [self presentViewController:vc animated:YES completion:^{
                [subscriber sendCompleted];
            }];
            return nil;
        }];
    }];
}

- (UITableView *)makeTableView {
    UITableView *t = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
    t.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    t.delegate = self;
    t.estimatedRowHeight = 100;
    t.rowHeight = UITableViewAutomaticDimension;
    [t registerClass:[UITableViewCell class] forCellReuseIdentifier:@"main"];
    return t;
}

- (void)loadView {
    @weakify(self);

    self.view = [[UIView alloc] initWithFrame:CGRectNonsense];
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
