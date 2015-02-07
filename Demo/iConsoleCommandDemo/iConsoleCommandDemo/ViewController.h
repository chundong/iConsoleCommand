//
//  ViewController.h
//  iConsoleCommandDemo
//
//  Created by chundong on 15/2/7.
//  Copyright (c) 2015年 chundong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CFCommandEngine.h"
#import "iConsole.h"
@interface ViewController : UIViewController<iConsoleDelegate>{
    CFCommandEngine *           _engine;
    UILabel*                    _label;
}


@end

