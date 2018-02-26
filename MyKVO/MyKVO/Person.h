//
//  Person.h
//  MyKVO
//
//  Created by FlyOceanFish on 2018/2/24.
//  Copyright © 2018年 FlyOceanFish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dog.h"

@interface Person : NSObject{
    @public
    NSString *_name;
    
    NSString *_sex;
}
@property (nonatomic,strong)NSString *sex;
@property (nonatomic,strong)Dog *dog;
@property (nonatomic,strong)NSMutableArray *arr;
@end
