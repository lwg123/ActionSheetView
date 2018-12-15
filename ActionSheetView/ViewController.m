//
//  ViewController.m
//  ActionSheetView
//
//  Created by weiguang on 2018/12/15.
//  Copyright © 2018年 duia. All rights reserved.
//

#import "ViewController.h"
#import "ActionSheetView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    ActionSheetView *actionView = [[ActionSheetView alloc] initWithTitle:@"更换头像" cellArray:@[@"照相", @"拍照"] cancelTitle:@"取消" selectedBlock:^(NSInteger index) {
        
        NSLog(@"点击了第%ld行",(long)index);
        
    } cancelBlock:^{
        NSLog(@"取消");
    }];
    
    [self.view.window addSubview:actionView];
}

@end
