//
//  PicassoPickerModule.m
//  Picasso
//
//  Created by 纪鹏 on 2018/2/8.
//

#import "PicassoPickerModule.h"
#import "PicassoThreadManager.h"
#import "PicassoHost.h"
#import "UIScreen+Adaptive.h"
#import "ReactiveCocoa.h"

static const CGFloat PCSPickerHeight = 266;
static const CGFloat PCSPickerToolBarHeight = 44;

@interface PicassoPickerViewController : UIViewController <UIPickerViewDelegate>
@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) PicassoCallBack *callback;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@property (nonatomic, strong) UIPickerView *picker;
@property (nonatomic, strong) NSArray *pickerItems;
@property (nonatomic, assign) NSInteger pickerIndex;


- (void)showDatePickerWithMode:(UIDatePickerMode)mode params:(NSDictionary *)params callback:(PicassoCallBack *)callback inViewController:(UIViewController *)controller;
- (void)showPickerWithItems:(NSArray *)itemArr index:(NSInteger)index callback:(PicassoCallBack *)callback inViewController:(UIViewController *)controller;

@end

@implementation PicassoPickerViewController

- (void)showPickerWithItems:(NSArray *)itemArr index:(NSInteger)index callback:(PicassoCallBack *)callback inViewController:(UIViewController *)controller {
    self.callback = callback;
    self.picker = [self createPickerViewWithItems:itemArr index:index];
    self.picker.frame = (CGRect){0, PCSPickerToolBarHeight, [UIScreen width], PCSPickerHeight - PCSPickerToolBarHeight};
    [self configPickerBgViewWithDoneSelector:@selector(donePicker)];
    [self.pickerView addSubview:self.picker];
    [self showPickerInViewController:controller];
}

- (UIPickerView *)createPickerViewWithItems:(NSArray *)itemArr index:(NSInteger)index {
    UIPickerView * picker = [[UIPickerView alloc] init];
    picker.backgroundColor = [UIColor whiteColor];
    picker.delegate = self;
    self.pickerItems = [itemArr copy];
    self.pickerIndex = index;
    if (self.pickerIndex < self.pickerItems.count) {
        [picker selectRow:self.pickerIndex inComponent:0 animated:NO];
    } else if (self.pickerItems.count > 0) {
        [picker selectRow:0 inComponent:0 animated:NO];
    }
    
    return picker;
}

- (void)donePicker {
    [self hidePicker];
    [self.callback sendSuccess:@{@"index":@(self.pickerIndex)}];
    self.callback = nil;
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerItems count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0f;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    id value = self.pickerItems[row];
    if ([value isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)value stringValue];
    }
    return value;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerIndex = row;
}


- (void)showDatePickerWithMode:(UIDatePickerMode)mode params:(NSDictionary *)params callback:(PicassoCallBack *)callback inViewController:(UIViewController *)controller {
    self.callback = callback;
    self.datePicker = [self createDatePickerViewWithMode:mode params:params];
    self.datePicker.frame = (CGRect){0, PCSPickerToolBarHeight, [UIScreen width], PCSPickerHeight - PCSPickerToolBarHeight};
    [self configPickerBgViewWithDoneSelector:@selector(doneDatePicker)];
    [self.pickerView addSubview:self.datePicker];
    [self showPickerInViewController:controller];
}


- (void)configPickerBgViewWithDoneSelector:(SEL)selector {
    self.bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.bgView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    
    self.pickerView = [[UIView alloc] initWithFrame:(CGRect){0, [UIScreen height], [UIScreen width], PCSPickerHeight}];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:(CGRect){0, 0, [UIScreen width], PCSPickerToolBarHeight}];
    toolbar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *marginItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    marginItem.width = 10;
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPicker)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:selector];
    [toolbar setItems:@[marginItem, cancelBtn, flexSpace, doneBtn, marginItem]];
    [self.pickerView addSubview:toolbar];
    [self.bgView addSubview:self.pickerView];
    [self.view addSubview:self.bgView];
}

- (UIDatePicker *)createDatePickerViewWithMode:(UIDatePickerMode)mode params:(NSDictionary *)params {
    NSDateFormatter *formatter = [self formatterForMode:mode];
    NSString *presetStr = params[@"preset"];
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = mode;
    datePicker.date = presetStr ? [formatter dateFromString:presetStr] : [NSDate date];
    if (mode == UIDatePickerModeDate) {
        NSString *minStr = params[@"min"];
        if (minStr) {
            datePicker.minimumDate = [formatter dateFromString:minStr];
        }
        NSString *maxStr = params[@"max"];
        if (maxStr) {
            datePicker.maximumDate = [formatter dateFromString:maxStr];
        }
    }
    datePicker.backgroundColor = [UIColor whiteColor];
    return datePicker;
}

- (void)doneDatePicker {
    [self hidePicker];
    NSString *dateStr = @"";
    if (UIDatePickerModeDate == self.datePicker.datePickerMode) {
        dateStr = [self.dateFormatter stringFromDate:self.datePicker.date];
    } else if (UIDatePickerModeTime == self.datePicker.datePickerMode) {
        dateStr = [self.timeFormatter stringFromDate:self.datePicker.date];
    }
    [self.callback sendSuccess:@{@"date":dateStr}];
    self.callback = nil;
}

- (void)cancelPicker {
    [self hidePicker];
    [self.callback sendSuccess:nil];
}

- (void)showPickerInViewController:(UIViewController *)controller {
    @weakify(self)
    [controller presentViewController:self animated:NO completion:^{
        @strongify(self)
        if (self.isAnimating) {
            return;
        }
        self.isAnimating = YES;
        self.bgView.hidden = NO;
        [UIView animateWithDuration:0.35f animations:^{
            self.pickerView.frame = (CGRect){0, [UIScreen height] - PCSPickerHeight, [UIScreen width], PCSPickerHeight};
            self.bgView.alpha = 1;
        } completion:^(BOOL finished) {
            self.isAnimating = NO;
        }];
    }];
}

- (void)hidePicker {
    if (self.isAnimating) {
        return;
    }
    self.isAnimating = YES;
    @weakify(self)
    [UIView animateWithDuration:0.35f animations:^{
        @strongify(self)
        self.pickerView.frame = CGRectMake(0, [UIScreen height], [UIScreen width], PCSPickerHeight);
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        @strongify(self)
        self.bgView.hidden = YES;
        self.isAnimating = NO;
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (NSDateFormatter *)formatterForMode:(UIDatePickerMode)mode {
    if (mode == UIDatePickerModeDate) {
        return self.dateFormatter;
    } else if (mode == UIDatePickerModeTime) {
        return self.timeFormatter;
    } else {
        return nil;
    }
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}

- (NSDateFormatter *)timeFormatter {
    if (!_timeFormatter) {
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"HH:mm"];
    }
    return _timeFormatter;
}

@end

@interface PicassoPickerModule ()

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *pickerView;
@property (nonatomic, strong) PicassoCallBack *callback;
@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation PicassoPickerModule

PCS_EXPORT_METHOD(@selector(pick:callback:))
PCS_EXPORT_METHOD(@selector(pickDate:callback:))
PCS_EXPORT_METHOD(@selector(pickTime:callback:))

- (void)pick:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    NSArray *items = params[@"items"];
    NSInteger index = [params[@"index"] integerValue];
    if ([self isValidItems:items]) {
        PCSRunOnMainThread(^{
            PicassoPickerViewController *pickerVC = [[PicassoPickerViewController alloc] init];
            pickerVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [pickerVC showPickerWithItems:items index:index callback:callback inViewController:self.host.pageController];
        });
    }
}

-(BOOL)isValidItems:(NSArray *)array
{
    if (![array isKindOfClass:[NSArray class]]) {
        return NO;
    }
    for (id value in array) {
        if([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
            continue;
        }else {
            return NO;
        }
    }
    return YES;
}

- (void)pickDate:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    PCSRunOnMainThread(^{
        [self createDatePicker:params mode:UIDatePickerModeDate callback:callback];
    });
}

- (void)pickTime:(NSDictionary *)params callback:(PicassoCallBack *)callback {
    PCSRunOnMainThread(^{
        [self createDatePicker:params mode:UIDatePickerModeTime callback:callback];
    });
}

- (void)createDatePicker:(NSDictionary *)params mode:(UIDatePickerMode)mode callback:(PicassoCallBack *)callback {
    PicassoPickerViewController *pickerVC = [[PicassoPickerViewController alloc] init];
    pickerVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [pickerVC showDatePickerWithMode:mode params:params callback:callback inViewController:self.host.pageController];
}

@end
