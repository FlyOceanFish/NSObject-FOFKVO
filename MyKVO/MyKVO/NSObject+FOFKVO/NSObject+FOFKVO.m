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
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) FOFObserveValueChanged block;

@end

@implementation FOFObserverInfo

- (instancetype)initWithObserver:(NSString *)observerName key:(NSString *)key block:(FOFObserveValueChanged)block
{
    self = [super init];
    if (self) {
        _observerName = observerName;
        _key = key;
        _block = block;
    }
    return self;
}

@end

@implementation NSObject (FOFKVO)

- (void)fof_addObserver:(NSObject *)observer forKey:(NSString *)key options:(NSKeyValueObservingOptions)options block:(nonnull FOFObserveValueChanged)block{
    NSString *setterStr = private_setterForKey(key);
    
    Method setterMethod = class_getInstanceMethod(self.class, NSSelectorFromString(setterStr));
    
    NSString *oldClassName = NSStringFromClass(self.class);
    NSString *kvoClassName = [@"FOFKVO_" stringByAppendingString:oldClassName];
    Class kvoClass;
    kvoClass = objc_lookUpClass(kvoClassName.UTF8String);
    if (!kvoClass) {
        kvoClass = objc_allocateClassPair(self.class, kvoClassName.UTF8String, 0);
        objc_registerClassPair(kvoClass);
    }
    
    
    if (setterMethod) {//直接调用setXX方法改变值
        class_addMethod(kvoClass,NSSelectorFromString(setterStr), (IMP)setterIMP, "v@:@");
    }else{//通过kvc改变值,通过method-swizzling
        Method method1 = class_getInstanceMethod(self.class, @selector(setValue:forKey:));
        Method method2 = class_getInstanceMethod(self.class, @selector(swizz_setValue:forKey:));
        method_exchangeImplementations(method1, method2);
    }
    object_setClass(self, kvoClass);
    FOFObserverInfo *info = [[FOFObserverInfo alloc] initWithObserver:observer.description key:key block:block];
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, kObservers, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
}
-(void)fof_removeObserver:(NSObject *)observer forKey:(NSString *)key context:(void *)context{
    NSMutableArray* observers = objc_getAssociatedObject(self, kObservers);
    
    FOFObserverInfo *info;
    for (FOFObserverInfo* temp in observers) {
        if ([temp.observerName isEqualToString:observer.description] && [temp.key isEqual:key]) {
            info = temp;
            break;
        }
    }
    if (info) {
        [observers removeObject:info];
    }else{
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not register observer for %@",observer.description,key] userInfo:nil];
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

#pragma mark - Private
#pragma mark swizz
-(void)swizz_setValue:(id)value forKey:(NSString *)key{
    id oldValue = [self valueForKey:key];
    [self swizz_setValue:value forKey:key];//如果这里没报错，说明正常设置值，现在开始回调
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    for (FOFObserverInfo *temp in observers) {
        if ([temp.key isEqualToString:key]) {
            temp.block(self, key, oldValue, value);
        }
    }
}

#pragma mark overrid
void setterIMP(id self,SEL _cmd,id newValue){
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *temp = private_upperTolower([setterName substringFromIndex:@"set".length], 0);//去除set并将大写改成小写
    NSString *key = [temp substringToIndex:temp.length-1];//去除冒号
    id oldValue = [self valueForKey:key];
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    ((void (*)(void *, SEL, id))objc_msgSendSuper)(&superClazz, _cmd, newValue);
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    for (FOFObserverInfo *temp in observers) {
        if ([temp.key isEqualToString:key]) {
            temp.block(self, key, oldValue, newValue);
        }
    }
}
#pragma mark inline
static force_inline NSString * private_setterForKey(NSString *key){
    key = private_lowerToUpper(key, 0);
    return [NSString stringWithFormat:@"set%@:",key];
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

