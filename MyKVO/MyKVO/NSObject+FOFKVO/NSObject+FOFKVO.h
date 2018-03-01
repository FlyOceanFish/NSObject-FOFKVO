//
//  NSObject+FOFKVO.h
//  MyKVO
//
//  Created by FlyOceanFish on 2018/2/24.
//  Copyright © 2018年 FlyOceanFish. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FOFObserveValueChanged)(id observedObject, NSString *key, id oldValue, id newValue);

@interface NSObject (FOFKVO)
- (void)fof_addObserver:(NSObject *)observer forKey:(NSString *)key options:(NSKeyValueObservingOptions)options block:(FOFObserveValueChanged)block;

- (void)fof_removeObserver:(NSObject *)observer forKey:(NSString *)key context:(nullable void *)context;
-(void)fof_removeObserver:(NSObject *)observer;
@end

NS_ASSUME_NONNULL_END

