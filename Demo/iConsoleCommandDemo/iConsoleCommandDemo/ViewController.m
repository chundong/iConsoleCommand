//
//  ViewController.m
//  iConsoleCommandDemo
//
//  Created by chundong on 15/2/7.
//  Copyright (c) 2015年 chundong. All rights reserved.
//

#import "ViewController.h"
#import "iConsole.h"
#import "CFCommandEngine.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _label = [[UILabel alloc] initWithFrame:self.view.frame];
    _label.text = @"command format : ctl.hello(1234567)";
    [self.view addSubview:_label];
    
    [iConsole sharedConsole].delegate = self;
 
    NSDictionary* bindObjs = @{
                               @"ctl":self
                               };
    _engine = [[CFCommandEngine alloc] initWithBindObject:bindObjs];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)hello:(NSString*) hello{
    [iConsole info:@"%s :%@ ",__func__,hello];
    _label.text = hello;
}

- (void)world{
    [iConsole info:@"world"];
}
#pragma mark -
#pragma mark iConsoleDelegate

- (void)handleConsoleCommand:(NSString *)command{
    BOOL ret = [_engine handleConsoleCommand:command];
    if (ret == NO) {
        [iConsole info:@"command not found"];
    }
}
@end
