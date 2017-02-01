@import AFNetworking;

#import "MainVC.h"
#import "LoginVC.h"
#import "PostCentaur.h"
#import "PostView.h"
#import "MainCell.h"
#import "MainStylesheet.h"

#define STYLESHEET ([MainStylesheet singleton])

@implementation Post

- (instancetype)initWithAuthor:(nonnull NSString *)author body:(nonnull NSString *)body {
    Post *post = [super init];
    post.author = author;
    post.body = body;
    return post;
}

@end

@interface PostsCentaur : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *posts;
@property (nonatomic, strong) NSIndexPath *highlightedIndexPath;
@property (nonatomic, strong) MainStylesheet *stylesheet;

@end

static PostCentaur *postOfJSON(NSDictionary *dict, NSDictionary *postsByID) {
    PostCentaur *centaur = [[PostCentaur alloc] init];
    centaur.post = [[Post alloc] initWithAuthor:dict[@"user"][@"name"] body:dict[@"content"]];

    NSNumber *parent = dict[@"idParent"];
    if (parent != nil) {
        NSString *content = postsByID[parent][@"content"];
        centaur.parent = [[Post alloc] initWithAuthor:postsByID[parent][@"user"][@"name"] body:[content ellipsize:100]];
    }
    return centaur;
}

static PostsCentaur *postsOfJSON(NSArray *array, MainStylesheet *stylesheet) {
    NSMutableDictionary *postsByID = [[NSMutableDictionary alloc] initWithCapacity:50];
    for (NSDictionary *post in array) {
        postsByID[post[@"id"]] = post;
    }
    NSArray *posts = [array.rac_sequence map:^id(NSDictionary *dict) {
        return postOfJSON(dict, postsByID);
    }].array;
    PostsCentaur *centaur = [[PostsCentaur alloc] init];
    centaur.stylesheet = stylesheet;
    centaur.posts = posts;
    return centaur;
}

static RACSignal *signalOfPosts(MainStylesheet *stylesheet) {
    AFHTTPSessionManager *m = [AFHTTPSessionManager manager];
    m.responseSerializer = [AFJSONResponseSerializer serializer];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [m GET:kAPI(@"/posts") parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable json) {
            [subscriber sendNext:postsOfJSON(json, stylesheet)];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
    cell.backgroundColor = self.stylesheet.backColor;
    cell.contentView.backgroundColor = self.stylesheet.frontColor;
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    PostView *view = [[PostView alloc] initWithFrame:CGRectNonsense];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.post = self.posts[indexPath.row];
    view.highlightedSignal = [RACObserve(self, highlightedIndexPath) map:^id(NSIndexPath *path) {
        return @([path isEqual:indexPath]);
    }];

    [RACObserve(self, highlightedIndexPath) logNext];
    [cell.contentView addSubview:view];
    [view autoPinEdgesToSuperviewMargins];
    return cell;
}


@end

@implementation MainVC

- (void)viewDidLoad {
    @weakify(self);

    NSParameterAssert(self.stylesheet);

    [super viewDidLoad];
    self.title = @"Divine Mercy";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:nil action:nil];
    self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        LoginVC *vc = [[LoginVC alloc] initWithNibName:nil bundle:nil];
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
    t.estimatedRowHeight = 1000;
    t.rowHeight = UITableViewAutomaticDimension;
    [t registerClass:[MainCell class] forCellReuseIdentifier:@"main"];
    return t;
}

- (void)loadView {
    @weakify(self);

    self.view = [[UIView alloc] initWithFrame:CGRectNonsense];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.backgroundColor = self.stylesheet.frontColor;

    self.tableView = [self makeTableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];

    RAC(self, posts) = [signalOfPosts(self.stylesheet) doNext:^(PostsCentaur *posts) {
        @strongify(self);
        self.tableView.dataSource = posts;
        [self.tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [UIView animateWithDuration:0.2
                          delay:0
         usingSpringWithDamping:0.75
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.tableView beginUpdates];
                         if ([self.posts.highlightedIndexPath isEqual:indexPath]) {
                             self.posts.highlightedIndexPath = nil;
                         } else {
                             self.posts.highlightedIndexPath = indexPath;
                         }
                         
                         [self.tableView endUpdates];
                     } completion:nil];
}

@end
