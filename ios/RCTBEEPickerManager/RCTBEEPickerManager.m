//
//  RCTBEEPickerManager.m
//  RCTBEEPickerManager
//
//  Created by MFHJ-DZ-001-417 on 16/9/6.
//  Copyright © 2016年 MFHJ-DZ-001-417. All rights reserved.
//

#import "RCTBEEPickerManager.h"
#import "BzwPicker.h"
#import "RCTEventDispatcher.h"

@interface RCTBEEPickerManager()

@property(nonatomic,strong)BzwPicker *pick;
@property(nonatomic,assign)float height;
@property(nonatomic,weak)UIWindow * window;
@property(nonatomic,strong)UIView * bgView;
@end

@implementation RCTBEEPickerManager

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(_init:(NSDictionary *)indic){
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow endEditing:YES];
    });
    
    self.window = [UIApplication sharedApplication].keyWindow;
    
    NSString *pickerConfirmBtnText=indic[@"pickerConfirmBtnText"];
    NSString *pickerCancelBtnText=indic[@"pickerCancelBtnText"];
    NSString *pickerTitleText=indic[@"pickerTitleText"];
    NSArray *pickerConfirmBtnColor=indic[@"pickerConfirmBtnColor"];
    NSArray *pickerCancelBtnColor=indic[@"pickerCancelBtnColor"];
    NSArray *pickerTitleColor=indic[@"pickerTitleColor"];
    NSArray *pickerToolBarBg=indic[@"pickerToolBarBg"];
    NSArray *pickerBg=indic[@"pickerBg"];
    NSArray *selectArry=indic[@"selectedValue"];
    NSArray *weightArry=indic[@"wheelFlex"];
    NSString *pickerToolBarFontSize=[NSString stringWithFormat:@"%@",indic[@"pickerToolBarFontSize"]];
    NSString *pickerFontSize=[NSString stringWithFormat:@"%@",indic[@"pickerFontSize"]];
    NSArray *pickerFontColor=indic[@"pickerFontColor"];
    
    id pickerData=indic[@"pickerData"];
    
    NSMutableDictionary *dataDic=[[NSMutableDictionary alloc]init];
    
    dataDic[@"pickerData"]=pickerData;
    
    [self.window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[BzwPicker class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [obj removeFromSuperview];
            });
        }
        if(obj.tag == 999){
            [obj removeFromSuperview];
            
        }
        
    }];
    //创建背景图
    self.bgView.alpha = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.window addSubview:self.bgView];
        
    });
    //创建picker
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0 ) {
        self.height=250;
    }else{
        self.height=220;
    }
    
    self.pick=[[BzwPicker alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.height) dic:dataDic leftStr:pickerCancelBtnText centerStr:pickerTitleText rightStr:pickerConfirmBtnText topbgColor:pickerToolBarBg bottombgColor:pickerBg leftbtnbgColor:pickerCancelBtnColor rightbtnbgColor:pickerConfirmBtnColor centerbtnColor:pickerTitleColor selectValueArry:selectArry weightArry:weightArry pickerToolBarFontSize:pickerToolBarFontSize pickerFontSize:pickerFontSize pickerFontColor:pickerFontColor];
    
    __weak typeof(self) weakSelf = self;
    _pick.bolock=^(NSDictionary *backinfoArry){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"----%@",backinfoArry);
            
            if([backinfoArry[@"type"] isEqualToString:@"cancel"] ||[backinfoArry[@"type"] isEqualToString:@"confirm"]){
                [UIView animateWithDuration:.3 animations:^{
                    weakSelf.bgView.alpha = 0;
                }];
            }
            
            
            [weakSelf.bridge.eventDispatcher sendAppEventWithName:@"pickerEvent" body:backinfoArry];
        });
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.window addSubview:_pick];
        
        [UIView animateWithDuration:.3 animations:^{
            [_pick setFrame:CGRectMake(0, SCREEN_HEIGHT-self.height, SCREEN_WIDTH, self.height)];
            
        }];
        
    });
    
}
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _bgView.backgroundColor = [UIColor blackColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click)];
        tap.numberOfTapsRequired = 1;
        [_bgView addGestureRecognizer:tap];
        _bgView.tag = 999;
    }
    return _bgView;
}
- (void)click{
    [self hide];
}
RCT_EXPORT_METHOD(show){
    if (self.pick) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                self.bgView.alpha = 0.3;
                [_pick setFrame:CGRectMake(0, SCREEN_HEIGHT-self.height, SCREEN_WIDTH, self.height)];
                
            }];
        });
    }
    return;
}

RCT_EXPORT_METHOD(hide){
    
    if (self.pick) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.3 animations:^{
                self.bgView.alpha = 0;
                [_pick setFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.height)];
            }];
        });
    }return;
}

RCT_EXPORT_METHOD(select: (NSArray*)data){
    
    if (self.pick) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _pick.selectValueArry = data;
            [_pick selectRow];
        });
    }return;
}

RCT_EXPORT_METHOD(isPickerShow:(RCTResponseSenderBlock)getBack){
    
    if (self.pick) {
        
        CGFloat pickY=_pick.frame.origin.y;
        
        if (pickY==SCREEN_HEIGHT) {
            
            getBack(@[@YES]);
        }else
        {
            getBack(@[@NO]);
        }
    }else{
        getBack(@[@"picker不存在"]);
    }
}

@end
