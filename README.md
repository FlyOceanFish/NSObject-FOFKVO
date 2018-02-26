# NSObject-FOFKVO
通过runtime自己实现了苹果的kvo,通过block实现了监听的回调
# 使用方法
* 添加监听
```
[xx fof_addObserver:self forKeyPath:@"sex" options:NSKeyValueObservingOptionNew block:^(id  _Nonnull observedObject, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"监听到了");
  }];
```
* 移除监听
```
[xx fof_removeObserver:self forKeyPath:@"sex" context:nil];
```
* 移除所有监听
```
[xx fof_removeObserver:(NSObject *)observer]
```

