//
//  ViewController.m
//  MyKVO
//
//  Created by FlyOceanFish on 2018/2/24.
//  Copyright © 2018年 FlyOceanFish. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Dog.h"
#import <objc/runtime.h>
#import "NSObject+FOFKVO.h"

//kvo监听不到数组的变化，因为kvo监听的是set方法

@interface ViewController ()
@property (nonatomic,strong)Person *p;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Person *p = [[Person alloc] init];
    //多个属性
//    [p addObserver:self forKeyPath:@"dog.age" options:NSKeyValueObservingOptionNew context:nil];
//    [p addObserver:self forKeyPath:@"dog.level" options:NSKeyValueObservingOptionNew context:nil];
//    [p addObserver:self forKeyPath:@"sex" options:NSKeyValueObservingOptionNew context:nil];
//    [p fof_addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    [p fof_addObserver:self forKeyPath:@"sex" options:NSKeyValueObservingOptionNew block:^(id  _Nonnull observedObject, NSString * _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
        NSLog(@"监听到了");
    }];
    _p = p;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    NSLog(@"%@",change);
    Class class = object_getClass(_p);
    
    NSLog(@"class---%@",_p.class);
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    static int a = 0;
//    _p->_name = [NSString stringWithFormat:@"%d",a++];
    _p.sex = [NSString stringWithFormat:@"%d",a++];
}
- (IBAction)removeObserver:(id)sender {
    
}
-(void)dealloc{
    [_p fof_removeObserver:self forKeyPath:@"sex" context:nil];
    NSLog(@"释放了");
}
@end
