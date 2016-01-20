//
//  UIViewController+Hock.m
//  Yundongli
//
//  Created by 吴恺 on 16/1/19.
//  Copyright © 2016年 wukai. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+Hock.h"

@implementation UIViewController (Hock)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = [self class];
    SEL originalSelector = @selector(viewDidLoad);
    SEL swizzledSelector = @selector(rcr_viewDidLoad);

    swizzleMethod(class, originalSelector, swizzledSelector);
  });
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
  Method originalMethod = class_getInstanceMethod(class, originalSelector);
  Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
  //  判断是否是可以添加original method
  BOOL didAddMethod = class_addMethod(class, originalSelector,
                                      method_getImplementation(swizzledMethod),
                                      method_getTypeEncoding(swizzledMethod));

  if (didAddMethod) {
    //    如果可以添加(没有实现original method),并将两个方法相互替换
    class_replaceMethod(class, swizzledSelector,
                        method_getImplementation(originalMethod),
                        method_getTypeEncoding(originalMethod));
  } else {
    //    如果不能添加(已经实现original
    //    method),将originalMethod与swizzledMethod替换
    method_exchangeImplementations(originalMethod, swizzledMethod);
  }
  //如果子类没有实现original方法,则getInstanceMehtod方法返回的是父类的方法,method_exchangeImplementation将swizzledMthod跟父类的方法进行调换,这不是我们想要的
}

- (void)rcr_viewDidLoad {
  [self rcr_viewDidLoad];  //调用的是originalMethod
                           //  self.view.backgroundColor = [UIColor whiteColor];
  if (![self
          isKindOfClass:
              NSClassFromString(
                  @"UIInputWindowController")]) {  //不加这个判断,view的整体颜色会被覆盖
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"viewDidLoad: %@", [self class]);
  }
}

@end
