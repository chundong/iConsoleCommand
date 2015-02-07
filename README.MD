iConsole的command一个扩展，主要是可以通过iConsole调用某些绑定的instance的方法来查看相关的对象。iConsole的handleConsoleCommand接口只要内置相关的命令就可以了。但是我想要更多的交互：调用绑定的实例对象的方法，得到更多的方法。

假设有一个instance a 有一个hello和world两个方法，如果使用iConsole的接口，代码如下：

- (void)handleConsoleCommand:(NSString *)command{

    if( [command isEqualToString:@"hello"] ){
        [a hello];
    }
    else if( [command isEqualToString:@"world"] ){
        [a world];
    }
}

而通过iConsoleCommand。可以写成

NSDictionary* bindObjs = @{
                               @"ctl":self
                               };
_engine = [[CFCommandEngine alloc] initWithBindObject:bindObjs];

在iConsole的delegate中写成。

BOOL ret = [_engine handleConsoleCommand:command];

这时，在iConsole的输入界面里面，直接输入a.hello()或者a.world()就可以执行相关的方法了。

也就是说可以通过增加bindObjs中绑定的instance。可以调用各种方法。


#TODO
现在的代码只能调用返回值为空，参数为字符串的情况，以后会增加更多的方法。


#坑

调用方法的时候是在主线中执行的，所以线程安全，线程卡死的问题也的考虑。

写这个是业余时间写的，所以质量没有太多的保证，我现在只是希望满足自己的项目需求就好。

