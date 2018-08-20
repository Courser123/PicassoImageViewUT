//
//  PICPlayground.m
//  Pods
//
//  Created by dawei on 9/6/16.
//
//

#import "PCSPlayground.h"
#import "PicassoView.h"
#import "PicassoInput.h"
#import "PicassoDebugMode.h"
#import "ReactiveCocoa.h"
#import "PicassoVCHost.h"
#import "UIView+Layout.h"

@interface PCSPlayground ()
@property (nonatomic, strong) PicassoView * picassoView;
@property (nonatomic, strong) PicassoInput * input;
@property (nonatomic, strong) PicassoVCHost *host;
@property (nonatomic, assign) BOOL isViewMode;
@property (nonatomic, strong) UIButton *switchBtn;
@end

@implementation PCSPlayground

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(picassofileChange:) name:PicassoDebugFileChangeNotification object:nil];
    }
    return self;
}

- (BOOL)handleWithSchemeModel:(id)urlAction {
    NSString * token = [urlAction valueForKey:@"token"];
    NSString * serverIP = [urlAction valueForKey:@"serverip"];
    self.token = token;
    self.serverip = serverIP;
    return YES;
}

- (BOOL)canHandleWithSchemeModel {
    return YES;
}

- (void)picassofileChange:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *resultDic = notification.object;
        if (![resultDic isKindOfClass:[NSDictionary class]]) return;
        self.picassoView.frame = self.view.bounds;
        if (self.isViewMode) {
            NSString *fileName = [[resultDic objectForKey:@"fileName"] componentsSeparatedByString:@"."].firstObject;
            self.input.jsName = fileName;
            self.input.width = self.view.frame.size.width;
            self.input.height = self.view.frame.size.height;
            self.input.jsContent = [resultDic objectForKey:@"content"];
            self.input.jsonData = @"{}";
            [[self.input computeSignal] subscribeCompleted:^{
                [self.picassoView painting:self.input];
            }];
        } else {
            NSString *jsContent = [resultDic objectForKey:@"content"];
            NSString *fileName = [[resultDic objectForKey:@"fileName"] componentsSeparatedByString:@"."].firstObject;
            if (jsContent.length) {
                [self.host destroyHost];
                self.host = [PicassoVCHost hostWithScript:jsContent options:[self options] data:nil];
                self.host.alias = fileName;
                [self.host updateVCState:PicassoVCStateLoad];
                [self.host callControllerMethod:@"onLiveLoad" argument:nil];
                [self.host layout];
                [self.host updateVCState:PicassoVCStateAppear];
                self.host.pageController = self;
                self.host.pcsView = self.picassoView;
            }
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.token.length > 0) {
        [[PicassoDebugMode instance] startMonitorWithToken:self.token];
    } else if (self.serverip.length > 0) {
        [[PicassoDebugMode instance] startMonitorWithIp:self.serverip];
    }

    self.edgesForExtendedLayout = UIRectEdgeNone;

    self.title = @"PicassoPlayground";
    self.view.backgroundColor = [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1];
    self.input = [PicassoInput new];
    self.picassoView = [[PicassoView alloc] init];
    [self.view addSubview:self.picassoView];
    
    self.switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchBtn.size = CGSizeMake(100, 30);
    self.switchBtn.alpha = 0.3;
    [self.switchBtn setBackgroundColor:[UIColor lightGrayColor]];
    [self.switchBtn setTitle:@"VC模式" forState:UIControlStateNormal];
    [self.switchBtn addTarget:self action:@selector(switchDebugMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.switchBtn];
    
    [self loadDefaultJS];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.switchBtn.bottom = self.view.height - 20;
    self.switchBtn.right = self.view.right;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.host updateVCState:PicassoVCStateAppear];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.host updateVCState:PicassoVCStateDisappear];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (NSDictionary *)options {
    return @{@"width"   :@(self.view.width),
             @"height"  :@(self.view.height)};
}

- (void)loadDefaultJS {
    NSString *content = @"  'use strict'; \
                            var _dp_picasso = require('@dp/picasso'); \
                            var extendStatics = Object.setPrototypeOf || \
                            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) || \
                            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; }; \
                            function __extends(d, b) { \
                            extendStatics(d, b); \
                            function __() { this.constructor = d; } \
                            d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __()); \
                            } \
                            var HelloPicasso = /** @class */ (function (_super) { \
                            __extends(HelloPicasso, _super); \
                            function HelloPicasso() { \
                            return _super !== null && _super.apply(this, arguments) || this; \
                            } \
                            HelloPicasso.prototype.layout = function () { \
                            var bg = _dp_picasso.View.viewWithFrame(0, 0, this.width, this.height); \
                            var tv = new _dp_picasso.TextView; \
                            tv.text = '欢迎使用Picasso调试页面, 请修改目标文件以使LiveLoad生效'; \
                            tv.textSize = 20; \
                            tv.width = bg.width - 40; \
                            tv.numberOfLines = 0; \
                            tv.sizeToFit(); \
                            tv.centerX = this.width / 2; \
                            tv.centerY = this.height / 2 - 40; \
                            bg.addSubView(tv); \
                            return bg; \
                            }; \
                            return HelloPicasso; \
                            }(_dp_picasso.VC)); \
                            Picasso.Page(HelloPicasso);";
    NSNotification *noti = [[NSNotification alloc] initWithName:PicassoDebugFileChangeNotification object:@{@"content": content} userInfo:nil];
    [self picassofileChange:noti];
}

- (void)switchDebugMode {
    self.isViewMode = !self.isViewMode;
    [self.switchBtn setTitle:self.isViewMode ? @"View模式" : @"VC模式" forState:UIControlStateNormal];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_host destroyHost];
}

#pragma Keyboard Notify

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.host keybordWillChangeToHeight:CGRectGetHeight(keyboardRect)];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self.host keybordWillChangeToHeight:0];
}

@end
