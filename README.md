# Block 原理本质

* block 本质也是一个OC对象,内部也有一个isa指针
* block 是封装了函数调用以及函数调用环境的OC对象

c++文件生成
`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m`

## Block 底层实现
### 没有参数没有返回值

```
       void (^block)(void) = ^{
            NSLog(@"return->Void; 参数->void");
        };

        block();
```


```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;

    /// 构造函数, 返回结构体对象
  __main_block_impl_0(void *fp,
                      struct __main_block_desc_0 *desc,
                      int flags=0) {

                /// block类型
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }

};

/// 封装了block的执行函数 fp->FuncPtr 
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_kb_015r8_pd5sz7t2_j_4v5v0wm0000gn_T_main_6822fe_mi_0);
        }

static struct __main_block_desc_0 {
  size_t reserved; // 0
  size_t Block_size; //block 在内存所占的大小
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        /// 定义block
        void (*block)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));

//        void (*block)(void) = &__main_block_impl_0(
//                                                   __main_block_func_0,
//                                                   &__main_block_desc_0_DATA);
        /// void (*block)(void) = &结构体(__main_block_impl_0)

        /// 执行block
        /// impl 内存地址就是 __main_block_impl_0的内存地址
        ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);


       /// block->FuncPtr(block);

    }
    return 0;
}
```

    
### 有参数没有返回值
**blcok 内部结构没发生改变,只是在fp 函数参数的改变**

```
    /// 02: 参数 没有返回值
    void(^block)(int,int) = ^(int a, int b){
        NSLog(@"return->void; 参数-%d--%d",a,b);
    };
    block(1,2);
```

```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself, int a, int b) {

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_kb_015r8_pd5sz7t2_j_4v5v0wm0000gn_T_main_e2d85c_mi_0,a,b);
        }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        
        void(*block)(int,int) = ((void (*)(int, int))&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
        
        ((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 1, 2);
    }
    return 0;
}

```

### block 捕获外部参数 

* 局部变量 -> auto -> 能捕获到block内部 -> 值传递 
* 局部变量 -> static -> 能捕获到block内部 -> 指针传递 
* 全局变量 -> 不能捕获 -> 直接访问 

```
    /// 自动变量 
    int a = 10;
    void(^block)(void) = ^{

        NSLog(@"外部参数----%d",a);
    };
    a = 20;
    block();
}
```


```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int a; /// 外部参数

    /// : a(_a)  传进来的_a 会自动赋值给成员a  a = _a
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _a, int flags=0) : a(_a) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }

};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int a = __cself->a; // 取block里面的a

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_kb_015r8_pd5sz7t2_j_4v5v0wm0000gn_T_main_648c76_mi_0,a);
        }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        int a = 10;

        void(*block)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, a));

        /// void(*block)(void) = &__main_block_impl_0(
//                                    __main_block_func_0,
//                                    &__main_block_desc_0_DATA,
//                                    a
//                                    );

        a = 20;
        ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
    }
    return 0;
}
```


```
    int number1 = 10;
    /// static 变量 
    static int number2 = 20;

    void(^block)(void) = ^{


        NSLog(@"局部变量: auto -> number1 -> %d  static -> number2 -> %d",number1, number2);
    };

    number1 = 1;
    number2 = 2;
    block();
}
```


```
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int number1;
  int *number2;

  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _number1, int *_number2, int flags=0) : number1(_number1), number2(_number2) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int number1 = __cself->number1; // 值
  int *number2 = __cself->number2; // 指针


            NSLog((NSString *)&__NSConstantStringImpl__var_folders_kb_015r8_pd5sz7t2_j_4v5v0wm0000gn_T_main_f23ea8_mi_0,number1, (*number2));
        }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        int number1 = 10;
        static int number2 = 20;

        void(*block)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0,
             &__main_block_desc_0_DATA,
             number1,
            &number2));

        number1 = 1;
        number2 = 2;
        ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
    }
    return 0;
}
```


```
    /// 04: 全局变量不会捕获, 直接访问
    void(^block)(void) = ^{
        NSLog(@"全局变量: number1->%d, number2->%d",number1_,number2_);
    };

    number1_ = 1;
    number2_ = 2;

    block();

    
}
```


```
int number1_ = 10;
static int number2_ = 20;


struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_kb_015r8_pd5sz7t2_j_4v5v0wm0000gn_T_main_52446d_mi_0,number1_,number2_);
        }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        void(*block)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));

        number1_ = 1;
        number2_ = 2;

        ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);


    }
    return 0;
}
```

## Block 类型

* __NSGlobalBlock__ (_NSConcreteStackBlock) 
* __NSMallocBlock__ (_NSConcreteMallocBlock)
* __NSStackBlock__ (_NSConcreteStackBlock)

![2018-05-22_14-37-31](https://github.com/BMMax/Block--/blob/master/Block-原理/img/2018-05-22_14-37-31.png)

### __NSGlobalBlock__
* 没有访问auto变量 


```

int number1_ = 10;
static int number2_ = 20;
```
```
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
```

```
2018-05-22 14:45:18.405703+0800 Block-原理[39373:3830645] block1类型---__NSGlobalBlock__
2018-05-22 14:45:18.406043+0800 Block-原理[39373:3830645] block2类型---__NSGlobalBlock__
2018-05-22 14:45:18.406065+0800 Block-原理[39373:3830645] block3类型---__NSGlobalBlock__
```

### __NSStackBlock__
* 访问了auto变量(MRC)
* 在ARC中,访问了auto变量->__NSMallocBlock


```
    int b = 20;
    void(^block4)(void) = ^ {
        NSLog(@"block4-----%d--",b);

    };
    NSLog(@"block4类型---%@",[block4 class]);
```

```
2018-05-22 14:58:38.775259+0800 Block-原理[39774:3854595] block4类型---__NSMallocBlock__
```

### __NSMallocBlock__
* __NSStackBlock__ 执行Copy


#### 执行copy情况

| 类型 | 原存储位置 | copy之后 |
| --- | --- | --- |
| _StackBlock | 栈 | 从栈复制到堆(mallocBlock) |
| _GlobalBlock | .data| noting to do  |
| _MallocBlock | 堆 | 引用计数+1 |



### __block 原理
* 使block内部修改捕获的auto变量
* 不能修饰全局,static 变量
* 会包装成一个对象`__Block_byref_a_0`


```
    __block int a = 10;
    void(^block)(void) = ^{
        a = 20;
        NSLog(@"__block-----a = %d",a);
    };

    block();
```


```
/// 包装成a的对象
struct __Block_byref_a_0 {
  void *__isa;
__Block_byref_a_0 *__forwarding; //指向自己
 int __flags;
 int __size;
 int a; // 10
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __Block_byref_a_0 *a; // __block 变量的地址
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_a_0 *_a, int flags=0) : a(_a->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
/// block 执行函数
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_a_0 *a = __cself->a; // bound by ref

            (a->__forwarding->a) = 20; //存入到 __Block_byref_a_0 结构体 a = 20
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_kb_015r8_pd5sz7t2_j_4v5v0wm0000gn_T_main_872d1f_mi_9,(a->__forwarding->a));
        }
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
        /// __ block
        __attribute__((__blocks__(byref))) __Block_byref_a_0 a = {
                                                                    (void*)0,
                                                                    (__Block_byref_a_0 *)&a,
                                                                    0,
                                                                    sizeof(__Block_byref_a_0),
                                                                    10

                                                                  };

        /// 定义block
        void(*block)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0,
                                                                &__main_block_desc_0_DATA,
                                                                (__Block_byref_a_0 *)&a,
                                                                570425344));

        /// 执行 
        ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
    }
    return 0;
}
```



