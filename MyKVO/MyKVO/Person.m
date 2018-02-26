//
//  Person.m
//  MyKVO
//
//  Created by FlyOceanFish on 2018/2/24.
//  Copyright © 2018年 FlyOceanFish. All rights reserved.
//

#import "Person.h"

@implementation Person

@dynamic sex;

-(instancetype)init{
    if (self=[super init]) {
        _dog = [[Dog alloc] init];
        _dog.age = 10;
        _arr = [NSMutableArray array];
    }
    return self;
}

//+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
//    return NO;
//}

+(NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key{
    NSMutableSet *keyPaths = [NSMutableSet set];
    if ([key isEqualToString:@"dog"]) {
        NSArray *array = @[@"_dog.age",@"_dog.level"];
        [keyPaths addObjectsFromArray:array];
    }
    return keyPaths;
}

-(void)setSex:(NSString *)sex{
    _sex = sex;
}
-(NSString *)getSex{
    return _sex;
}

@end
