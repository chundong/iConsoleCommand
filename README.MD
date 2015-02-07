iConsole的command一个扩展，主要是可以通过iConsole调用某些绑定的instance的方法来查看相关的对象。iConsole的handleConsoleCommand接口只要内置相关的命令就可以了。但是我想要更多的交互：调用绑定的实例对象的方法，得到更多的方法。

假设有一个instance a 有一个hello和world两个方法，如果使用iConsole的接口，代码如下：
<pre>

- (void)handleConsoleCommand:(NSString *)command{

    if( [command isEqualToString:@"hello"] ){
        [a hello];
    }
    else if( [command isEqualToString:@"world"] ){
        [a world];
    }
}

</pre>
而通过iConsoleCommand。可以写成
<pre>
NSDictionary* bindObjs = @{
                               @"a":self
                               };
_engine = [[CFCommandEngine alloc] initWithBindObject:bindObjs];
</pre>
在iConsole的delegate中写成。

<pre>
BOOL ret = [_engine handleConsoleCommand:command];
</pre>
这时，在iConsole的输入界面里面，直接输入a.hello()或者a.world()就可以执行相关的方法了。

具体的可以见Demo.

也就是说可以通过增加bindObjs中绑定的instance。可以调用各种方法。


#TODO
现在的代码只能调用返回值为空，参数为字符串的情况，以后会增加更多的方法。


#坑

调用方法的时候是在主线中执行的，所以线程安全，线程卡死的问题也的考虑。


写这个是业余时间写的，专注解决我自己的问题，所以质量无法保证太多，坑多慎入。

#Tips
因为回调函数，所以输入会比较多，请把iPhone，iPad 连接到蓝牙键盘后才开始调试。方便输入。

