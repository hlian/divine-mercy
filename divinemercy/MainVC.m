#import "MainVC.h"
#import "LoginVC.h"
#import "PostCentaur.h"
#import "PostView.h"

@interface PostsCentaur : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSIndexPath *highlightedIndexPath;

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.posts.highlightedIndexPath = indexPath;
}

@end
