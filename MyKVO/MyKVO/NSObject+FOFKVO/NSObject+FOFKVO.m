//
//  NSObject+FOFKVO.m
//  MyKVO
//
//  Created by FlyOceanFish on 2018/2/24.
//  Copyright © 2018年 FlyOceanFish. All rights reserved.
//

#import "NSObject+FOFKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

static char const * kObservers= "FOFOBSERVERS";

#define force_inline __inline__ __attribute__((always_inline))

#pragma mark - FOFObserverInfo
@interface FOFObserverInfo : NSObject

@property (nonatomic, copy) NSString *observerName;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, copy) FOFObserveValueChanged block;

@end

@implementation FOFObserverInfo

- (instancetype)initWithObserver:(NSString *)observerName keyPath:(NSString *)keyPath block:(FOFObserveValueChanged)block
{
    self = [super init];
    if (self) {
        _observerName = observerName;
        _keyPath = keyPath;
        _block = block;
    }
    return self;
}

@end

@implementation NSObject (FOFKVO)

- (void)fof_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options block:(nonnull FOFObserveValueChanged)block{
    NSString *setterStr = private_setterForKey(keyPath);
    Method setterMethod = class_getInstanceMethod(self.class, NSSelectorFromString(setterStr));
    if (!setterMethod) {
        return;
    }
    NSString *oldClassName = NSStringFromClass(self.class);
    NSString *kvoClassName = [@"FOFKVO_" stringByAppendingString:oldClassName];
    Class kvoClass;
    kvoClass = objc_lookUpClass(kvoClassName.UTF8String);
    if (!kvoClass) {
        kvoClass = objc_allocateClassPair(self.class, kvoClassName.UTF8String, 0);
        objc_registerClassPair(kvoClass);
    }

    object_setClass(self, kvoClass);
    
    class_addMethod(kvoClass,NSSelectorFromString(setterStr), (IMP)setterIMP, "v@:@");
    FOFObserverInfo *info = [[FOFObserverInfo alloc] initWithObserver:observer.description keyPath:keyPath block:block];
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, kObservers, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}
-(void)fof_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context{
    NSMutableArray* observers = objc_getAssociatedObject(self, kObservers);
    
    FOFObserverInfo *info;
    for (FOFObserverInfo* temp in observers) {
        if ([temp.observerName isEqualToString:observer.description] && [temp.keyPath isEqual:keyPath]) {
            info = temp;
            break;
        }
    }
    if (info) {
        [observers removeObject:info];
    }else{
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not register observer for %@",observer.description,keyPath] userInfo:nil];
    }

}
-(void)fof_removeObserver:(NSObject *)observer{
    NSMutableArray* observers = objc_getAssociatedObject(self, kObservers);
    NSMutableArray *array = [NSMutableArray array];
    for (FOFObserverInfo* temp in observers) {
        if ([temp.observerName isEqualToString:observer.description]) {
            [array addObject:temp];
        }
    }
    if (array.count) {
        [observers removeObjectsInArray:array];
    }
}

void setterIMP(id self,SEL _cmd,id newValue){
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *temp = private_upperTolower([setterName substringFromIndex:@"set".length], 0);//去除set并将大写改成小写
    NSString *keyPath = [temp substringToIndex:temp.length-1];//去除冒号
    id oldValue = [self valueForKey:keyPath];
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    ((void (*)(void *, SEL, id))objc_msgSendSuper)(&superClazz, _cmd, newValue);
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    for (FOFObserverInfo *temp in observers) {
        if ([temp.keyPath isEqualToString:keyPath]) {
            temp.block(self, keyPath, oldValue, newValue);
        }
    }
}

static force_inline NSString * private_setterForKey(NSString *keyPath){
    keyPath = private_lowerToUpper(keyPath, 0);
    return [NSString stringWithFormat:@"set%@:",keyPath];
}

static force_inline NSString * private_lowerToUpper(NSString *str,NSInteger location){
    NSRange range = NSMakeRange(location, 1);
    NSString *lowerLetter = [str substringWithRange:range];
    return [str stringByReplacingCharactersInRange:range withString:lowerLetter.uppercaseString];
}
static force_inline NSString * private_upperTolower(NSString *str,NSInteger location){
    NSRange range = NSMakeRange(location, 1);
    NSString *lowerLetter = [str substringWithRange:range];
    return [str stringByReplacingCharactersInRange:range withString:lowerLetter.lowercaseString];
}
@end
