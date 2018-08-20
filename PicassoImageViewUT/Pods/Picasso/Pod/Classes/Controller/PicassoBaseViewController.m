//
//  PicassoViewController.m
//  Pods
//
//  Created by 纪鹏 on 2017/5/3.
//
//

#import "PicassoBaseViewController.h"
#import "PicassoVCHost.h"
#import "PicassoView.h"
#import "UIView+Layout.h"
#import "PicassoDebugMode.h"
#import "UIViewController+Picasso.h"
#import "PicassoUtility.h"

@interface PicassoBaseViewController ()
@property (nonatomic, strong) PicassoVCHost *host;
@property (nonatomic, strong) PicassoView *pcsView;
@property (nonatomic, assign) CGSize lastViewSize;
@end

@implementation PicassoBaseViewController

- (instancetype)init {
    if (self = [super init]) {
        if ([PicassoUtility isDebug]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picassofileChange:) name:PicassoDebugFileChangeNotification object:nil];
        }
    }
    return self;
}

- (void)loadView {
    _pcsView = [[PicassoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _pcsView.backgroundColor = [UIColor whiteColor];
    _pcsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = _pcsView;
}


- (void)picassofileChange:(NSNotification *)n {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *resultDic = n.object;
        if ([resultDic isKindOfClass:[NSDictionary class]]) {
            NSString *jsContent = [resultDic objectForKey:@"content"];
            if (jsContent.length) {
                [self.host destroyHost];
                self.host = [PicassoVCHost hostWithScript:jsContent options:@{@"width":@(self.lastViewSize.width),@"height":@(self.lastViewSize.height)} data:nil];
                [self.host updateVCState:PicassoVCStateLoad];
                [self.host callControllerMethod:@"onLiveLoad" argument:nil];
                [self.host layout];
                [self.host updateVCState:PicassoVCStateAppear];
                self.host.pageController = self;
                self.host.pcsView = self.pcsView;
            }
        }
    });
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat renderHeight = self.pcsView.height - (self.navigationController.navigationBar.hidden?0:self.navigationController.navigationBar.bottom) - (self.tabBarController.tabBar.hidden?0:self.tabBarController.tabBar.height);
    self.lastViewSize = CGSizeMake(self.pcsView.width, renderHeight);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.jsName ofType: @"js"];
    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    self.host = [PicassoVCHost hostWithScript:self.jsName?jsScript:self.jsScript options:[self options] data:nil];
    [self.host updateVCState:PicassoVCStateLoad];
    [self.host layout];
    self.host.pageController = self;
    self.host.pcsView = self.pcsView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = self.pcs_navibarHidden;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = false;
}
 
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.host updateVCState:PicassoVCStateAppear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.host updateVCState:PicassoVCStateDisappear];
}

- (NSDictionary *)options {
    return @{@"width"   :@(self.lastViewSize.width),
             @"height"  :@(self.lastViewSize.height)};
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGSizeEqualToSize(self.lastViewSize, self.view.size)) {
        self.lastViewSize = self.view.size;
        [self.host notifyViewFrameChanged:[self options]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"viewcontroller dealloc");
    if ([PicassoUtility isDebug]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [_host destroyHost];
}

@end
