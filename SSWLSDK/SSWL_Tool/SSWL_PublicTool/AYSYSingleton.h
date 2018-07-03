//
//  AYSYSingleton.h
//  AYSDK
//
//  Created by SDK on 2017/7/24.
//  Copyright © 2017年 SDK. All rights reserved.
//

#ifndef AYSYSingleton_h
#define AYSYSingleton_h


#endif /* AYSYSingleton_h */
//将单例定义为宏，，这里定义了ARC模式下的单例；

// .h文件的实现
#define SYSingletonH(methodName) + (instancetype)shared##methodName;


// .m文件的实现
#define SYSingletonM(methodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
if (_instace == nil) { \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super allocWithZone:zone]; \
}); \
} \
return _instace; \
} \
\
- (id)init \
{ \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_instace = [super init]; \
}); \
return _instace; \
} \
\
+ (instancetype)shared##methodName \
{ \
return [[self alloc] init]; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
return _instace; \
} \
+ (id)copy\
{ \
return _instace; \
} \
\
+ (id)mutableCopy\
{ \
return _instace; \
}




