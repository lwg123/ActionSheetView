//
//  ActionSheetView.m
//  DuiFuDao
//
//  Created by weiguang on 2018/8/6.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import "ActionSheetView.h"
#import "UIColor+Utils.h"

#define Space_Line 7
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define IS_iPhoneX  isIPhoneXSeries()
// 判断是否是iPhone X/XS/XR/XS Max
static inline BOOL isIPhoneXSeries() {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}


@interface ActionSheetView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView *maskView;//背景
@property (nonatomic, strong) UITableView *tableView;//展示表格
@property (nonatomic, strong) NSMutableArray *cellArray;//表格数组
@property (nonatomic, copy) NSString *cancelTitle;//取消的标题设置
@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) void(^selectedBlock)(NSInteger);//选择单元格block
@property (nonatomic, copy) void(^cancelBlock)(void);//取消单元格block

@end


@implementation ActionSheetView

-(instancetype)initWithTitle:(NSString *)title cellArray:(NSArray *)cellArray cancelTitle:(NSString *)cancelTitle selectedBlock:(void (^)(NSInteger index))selectedBlock cancelBlock:(void (^)(void))cancelBlock
{
    self = [super init];
    if (self) {
        _title = title;
        _cellArray = cellArray.mutableCopy;
        [_cellArray insertObject:title atIndex:0];
        _cancelTitle = cancelTitle;
        _selectedBlock = selectedBlock;
        _cancelBlock = cancelBlock;
        
        //创建UI视图
        [self createUI];
    }
    return self;
}

#pragma mark ------ 创建UI视图
- (void)createUI {
    self.frame = [UIScreen mainScreen].bounds;
    //背景
    [self addSubview:self.maskView];
    //表格
    [self addSubview:self.tableView];
}


- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.35];
        _maskView.userInteractionEnabled = YES;
        if (IS_iPhoneX) {
            UIView *bottomV = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_maskView.frame)-30, SCREEN_WIDTH, 30)];
            bottomV.backgroundColor = [UIColor colorWithHex:0xF2F2F2];
            [_maskView addSubview:bottomV];
        }
    }
    return _maskView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 49.0;
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorInset = UIEdgeInsetsMake(0, -50, 0, 0);
        _tableView.separatorColor = [UIColor colorWithHex:0xE5E5E5];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"OneCell"];
    }
    return _tableView;
}



#pragma mark <UITableViewDelegate,UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return (section == 0)?_cellArray.count:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OneCell"];
    if (indexPath.section == 0) {
        cell.textLabel.text = _cellArray[indexPath.row];
        if (indexPath.row == 0) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
        }else {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
        }
        
    } else {
        cell.textLabel.text = _cancelTitle;
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }

    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return;
        }
        if (self.selectedBlock) {
            self.selectedBlock(indexPath.row);
        }
    } else {
        if (self.cancelBlock) {
            self.cancelBlock();
        }
    }
    [self dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return Space_Line;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section != 0) {
        return [UIView new];
    }
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, Space_Line)];
    footerView.backgroundColor = [UIColor colorWithHex:0xF2F2F2];
    return footerView;
}

#pragma mark ------ 绘制视图
- (void)layoutSubviews {
    [super layoutSubviews];
    [self show];
}

//滑动弹出
- (void)show {
    CGFloat top = SCREEN_HEIGHT;
    if (IS_iPhoneX) {
        top -= 30;
    }
    _tableView.frame = CGRectMake(0, top, SCREEN_WIDTH, _tableView.rowHeight * (_cellArray.count+1));
    [UIView animateWithDuration:.5 animations:^{
        CGRect rect = self->_tableView.frame;
        rect.origin.y -= self->_tableView.bounds.size.height;
        self->_tableView.frame = rect;
    }];
}
//滑动消失
- (void)dismiss {
    [UIView animateWithDuration:.5 animations:^{
        CGRect rect = self->_tableView.frame;
        rect.origin.y += self->_tableView.bounds.size.height;
        self->_tableView.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark ------ 触摸屏幕其他位置弹下
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismiss];
}

@end
