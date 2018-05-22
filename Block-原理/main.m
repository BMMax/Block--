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


void(^block_)(void);
void test() {
    int a = 10;
    void(^block)(void) = ^ {
        NSLog(@"text---block----%d",a);
    };

    block_ = block;
}


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
//        void(^block)(void) = ^{
//            NSLog(@"全局变量: number1->%d, number2->%d",number1_,number2_);
//        };
//
//        number1_ = 1;
//        number2_ = 2;
//
//        block();



        //// block 类型
        void(^block1)(void) = ^ {
            NSLog(@"block1-----");
        };

        NSLog(@"block1类型---%@",[block1 class]);

        static int a = 10;
        void(^block2)(void) = ^ {
            NSLog(@"block1-----%d",a);
        };
        NSLog(@"block2类型---%@",[block2 class]);

        void(^block3)(void) = ^ {
            NSLog(@"block3-----%d---%d",number1_,number2_);
        };
        NSLog(@"block3类型---%@",[block3 class]);



        int b = 20;
        void(^block4)(void) = ^ {
            NSLog(@"block4-----%d--",b);

        };
        NSLog(@"block4类型---%@",[block4 class]);

        test();
        block_();

    }
    return 0;
}

