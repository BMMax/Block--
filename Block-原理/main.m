//
//  main.m
//  Block-原理
//
//  Created by user on 2018/5/22.
//  Copyright © 2018年 mobin. All rights reserved.
//

#import <Foundation/Foundation.h>

int number1_ = 10;
static int number2_ = 20;

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        /// 00 -> 没有参数没有返回值
//        void (^block)(void) = ^{
//            NSLog(@"return->Void; 参数->void");
//        };
//
//        block();

        /// 01: 参数 没有返回值
//        void(^block)(int,int) = ^(int a, int b){
//            NSLog(@"return->void; 参数-%d--%d",a,b);
//        };
//        block(1,2);

        ///02: auto 局部变量
//        int a = 10;
//        void(^block)(void) = ^{
//
//            NSLog(@"外部参数----%d",a);
//        };
//        a = 20;
//        block();

        ///03: static 捕获
//        int number1 = 10;
//        static int number2 = 20;
//
//        void(^block)(void) = ^{
//
//
//            NSLog(@"局部变量: auto -> number1 -> %d  static -> number2 -> %d",number1, number2);
//        };
//
//        number1 = 1;
//        number2 = 2;
//        block();

        /// 04: 全局变量不会捕获
        void(^block)(void) = ^{
            NSLog(@"全局变量: number1->%d, number2->%d",number1_,number2_);
        };

        number1_ = 1;
        number2_ = 2;

        block();

        
    }
    return 0;
}
