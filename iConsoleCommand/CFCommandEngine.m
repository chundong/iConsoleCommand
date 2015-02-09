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
static void (*void_method_invoke_void)(id, Method) = (void (*)(id, Method)) method_invoke;
static void (*void_method_invoke_id)(id, Method, id) = (void (*)(id, Method, id)) method_invoke;
static id (*id_method_invoke_id)(id, Method, id) = (id (*)(id, Method, id)) method_invoke;
static id (*id_method_invoke_void)(id, Method) = (id (*)(id, Method)) method_invoke;

@implementation CFCommandEngine
//@synthesize bindObjects = _bindObjects;
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
                    if ([arg isEqualToString:@""] == NO) {
                        [argArray addObject:arg];
                    }
                    
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
    if (argArray.count > 0) {
        dict[@"property"] = [NSString stringWithFormat:@"set%c%@" ,toupper([func characterAtIndex:0]),[func substringFromIndex:1] ];
    }else if (argArray.count == 0){
        dict[@"property"] = [NSString stringWithFormat:@"get%c%@" ,toupper([func characterAtIndex:0]),[func substringFromIndex:1] ];
    }
    
    dict[@"args"] = argArray;
    return dict;
}

- (void)appendBindObjs:(NSDictionary*)appendDict{
    [_bindObjects setValuesForKeysWithDictionary:appendDict];
}

- (BOOL)executeMethod:(NSDictionary*)dict withInstance:(id)insta andClass:(Class) cls{
    BOOL ret = NO;
    
    unsigned int count = 0;
    Method* methods = class_copyMethodList(cls, &count);
    Method targetMethod = NULL;
    NSString* returnType = nil;
    
    NSString* funcationName = dict[@"function"];
    
    for (unsigned int i = 0; i < count; i++) {
        Method m = methods[i];
        SEL sel = method_getName(m);
        
        NSString* selName = [NSString stringWithFormat:@"%s",sel_getName(sel )];
        char dst[1024];
        memset(dst, 0, 1024);
        
        method_getReturnType(m,dst,1024);
        
//        NSLog(@"class = %s retType == %s sel = %@ funcationName = %@ ",class_getName(cls), dst,selName,funcationName);
        
        if ([selName isEqualToString:funcationName] || [selName isEqualToString:dict[@"property"]]) {
            returnType = [NSString stringWithFormat:@"%s",dst];
            targetMethod = m;
        }
    }
    
    if (targetMethod)
    {
        ret = YES;
        switch ([dict[@"args"] count]) {
            case 0:
                //TODO 这个地方使用isEqualToString感觉不怎么好，主要是对method_getReturnType整个方法不是太了解。后面优化。
                if ([returnType isEqualToString:@"v"]) {
                    void_method_invoke_void(insta,targetMethod);
                }else if([returnType isEqualToString:@"@"]){
                    id retVal = id_method_invoke_void(insta,targetMethod);
                    [iConsole info:@"retVal = %@",retVal];
                }
                
                break;
            case 1:
                
                if ([returnType isEqualToString:@"v"]) {
                    void_method_invoke_id(insta,targetMethod,dict[@"args"][0]);
                }else if([returnType isEqualToString:@"@"]){
                    id retVal = id_method_invoke_id(insta,targetMethod,dict[@"args"][0]);
                    [iConsole info:@"retVal = %@",retVal];
                }
                break;
                
            default:
                break;
        }
    }else{
        if (class_getSuperclass(cls)) {
            [self executeMethod:dict withInstance:insta andClass:class_getSuperclass(cls)];
        }
    }
    free(methods);
    
    return ret;
}

- (BOOL)handleConsoleCommand:(NSString *)command
{
    BOOL ret = NO;
    
    if ([command rangeOfString:@"."].location != NSNotFound) {
        
        NSDictionary* parseResult = [self parseCommand:command];
        
        if (_bindObjects[parseResult[@"instance"]])
        {
            NSObject* insta = _bindObjects[parseResult[@"instance"]];
            
            ret = [self executeMethod:parseResult withInstance:insta andClass:[insta class]];
            
        }
    }
    if (ret == NO) {
        [iConsole info:@"no suth command"];
    }
    return ret;
    
}
@end
