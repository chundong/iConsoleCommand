//
//  CFCommandEngine.m
//  iConsoleCommandDemo
//
//  Created by chundong on 15/2/7.
//  Copyright (c) 2015年 chundong. All rights reserved.
//

#import "CFCommandEngine.h"
#import <objc/objc.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "iConsole.h"

#define PARSE_OBJ_NAME 0
#define PARSE_FUNCTION 1
#define PARSE_ARG 2
//http://stackoverflow.com/questions/19694173/using-objective-cs-invoke-method-to-call-a-void-method-under-arc
static void (*_method_invoke_void_void)(id, Method, ...) = (void (*)(id, Method, ...)) method_invoke;
static void (*_method_invoke_void_string)(id, Method, NSString*) = (void (*)(id, Method, NSString*)) method_invoke;
//static id (*_method_invoke_id_id)(id, Method, ...) = (id (*)(id, Method, ...)) method_invoke;

@implementation CFCommandEngine
@synthesize bindObjects = _bindObjects;
- (id)initWithBindObject:(NSDictionary*)dict{
    self = [super init];
    if (self) {
        if (dict) {
            _bindObjects = [[NSMutableDictionary alloc] initWithDictionary:dict];
        }else{
            _bindObjects = [[NSMutableDictionary alloc] initWithCapacity:10];
        }
    }
    return self;
}
- (NSDictionary*)parseCommand:(NSString*) command{

    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    int status = PARSE_OBJ_NAME;
    
    NSMutableArray* argArray = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableString* insta = [[NSMutableString alloc] initWithCapacity:10];
    NSMutableString* arg = nil; //[[NSMutableString alloc] initWithCapacity:10];
    NSMutableString* func = [[NSMutableString alloc] initWithCapacity:20];
    
    for ( int i = 0; i < [command length];i++){
        unichar c = [command characterAtIndex:i];
        switch (status) {
            case PARSE_OBJ_NAME:{
                if ( c != '.') {
                    [insta appendString:[NSString stringWithFormat:@"%C",c]];
                }else{
                    status = PARSE_FUNCTION;
                }
                break;
            }
            case PARSE_FUNCTION:
                if (isalpha(c)) {
                    [func appendString:[NSString stringWithFormat:@"%C",c]];
                    
                }else if(c == '.'){
                    //
                }else if(c == '('){
                    status = PARSE_ARG;
                    
                    arg = [[NSMutableString alloc] initWithCapacity:10];
                }
                break;
            case PARSE_ARG:
                if(c == ')'){
                    if ([arg length] > 0) {
                        [func appendString:@":"];
                    }
                    
                    status = PARSE_FUNCTION;
                    [argArray addObject:arg];
                }else{
                    [arg appendString:[NSString stringWithFormat:@"%C",c]];
                }
                
                break;
            default:
                break;
        }
        
    }
    dict[@"instance"] = insta ;
    dict[@"function"] = func ;
    dict[@"property"] = [NSString stringWithFormat:@"set%c%@" ,toupper([func characterAtIndex:0]),[func substringFromIndex:1] ];
    dict[@"args"] = argArray;
    return dict;
}

- (BOOL)handleConsoleCommand:(NSString *)command
{
    BOOL ret = NO;
    
    if ([command rangeOfString:@"."].location != NSNotFound) {
        
        NSDictionary* parseResult = [self parseCommand:command];
        
        NSString* funcationName = parseResult[@"function"];

        if (_bindObjects[parseResult[@"instance"]])
        {
            NSObject* obj = _bindObjects[parseResult[@"instance"]];
            
            unsigned int count = 0;
            Method* methods = class_copyMethodList([obj class], &count);
            Method targetMethod = NULL;
            for (unsigned int i = 0; i < count; i++) {
                Method m = methods[i];
                SEL sel = method_getName(m);
                
                NSString* selName = [NSString stringWithFormat:@"%s",sel_getName(sel )];
                
                if ([selName isEqualToString:funcationName] || [selName isEqualToString:parseResult[@"property"]]) {
                    targetMethod = m;
                }
            }
            
            if (targetMethod)
            {
                ret = YES;
                switch ([parseResult[@"args"] count]) {
                    case 0:
                        _method_invoke_void_void(obj,targetMethod);
                        break;
                    case 1:
                        _method_invoke_void_string(obj,targetMethod,parseResult[@"args"][0]);
                        break;
                        
                    default:
                        break;
                }
            }else{
                [iConsole warn:@"no method"];
            }
            free(methods);
            
            
            
        }
    } 
    return ret;
    
}
@end
