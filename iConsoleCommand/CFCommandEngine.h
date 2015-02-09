//
//  CFCommandEngine.h
//  iConsoleCommandDemo
//
//  Created by chundong on 15/2/7.
//  Copyright (c) 2015年 chundong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFCommandEngine : NSObject{
    NSMutableDictionary*  _bindObjects;
}
//@property (nonatomic, strong)NSMutableDictionary* bindObjects;

- (id)initWithBindObject:(NSDictionary*)dict;
- (BOOL)handleConsoleCommand:(NSString *)command;
@end
