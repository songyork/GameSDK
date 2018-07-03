//
//  SongyorkInfo.m
//  SDK
//
//  Created by songyan on 2017/8/15.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "SongyorkInfo.h"
#import <objc/message.h>
@implementation SongyorkInfo


- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.proId forKey:@"proId"];
    
    [aCoder encodeObject:self.productName forKey:@"productName"];
    
    [aCoder encodeObject:self.money forKey:@"money"];

    [aCoder encodeObject:self.serverId forKey:@"serverId"];
    
    [aCoder encodeObject:self.moneyType forKey:@"moneyType"];
    
    [aCoder encodeObject:self.uid forKey:@"uid"];
    
    [aCoder encodeObject:self.roleId forKey:@"roleId"];
    
    [aCoder encodeObject:self.roleName forKey:@"roleName"];
    
    [aCoder encodeObject:self.YYY forKey:@"YYY"];
    
    [aCoder encodeObject:self.appId forKey:@"appId"];
   
}


- (id)initWithCoder:(NSCoder *)aDecoder{

    self.proId = [aDecoder decodeObjectForKey:@"proId"];

    self.productName = [aDecoder decodeObjectForKey:@"productName"];
    
    self.money = [aDecoder decodeObjectForKey:@"money"];
    
    self.moneyType = [aDecoder decodeObjectForKey:@"moneyType"];
    
    self.serverId = [aDecoder decodeObjectForKey:@"serverId"];
    
    self.uid = [aDecoder decodeObjectForKey:@"uid"];
    
    self.roleId = [aDecoder decodeObjectForKey:@"roleId"];
    
    self.roleName = [aDecoder decodeObjectForKey:@"roleName"];
    
    self.YYY = [aDecoder decodeObjectForKey:@"YYY"];
    
    self.appId = [aDecoder decodeObjectForKey:@"appId"];
    
   
    return self;
}


- (BOOL)paramterIsNilShowToViewController:(UIViewController *)viewController{
    //是否是nil
    NSMutableDictionary *paramterDict = [NSMutableDictionary dictionary];
    unsigned count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        objc_property_t propertyValue = properties[i];
        const char *propertyName = property_getName(propertyValue);
        SEL getSeletor = NSSelectorFromString([NSString stringWithUTF8String:propertyName]);
        
        if ([self respondsToSelector:getSeletor]) {
            NSMethodSignature *signature = [self methodSignatureForSelector:getSeletor];//方法签名
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];//调用对象
            [invocation setTarget:self];//设置target
            [invocation setSelector:getSeletor];//设置selector
            NSObject *__unsafe_unretained returnValue = nil;//设置返回值
            [invocation invoke];//开始调用
            [invocation getReturnValue:&returnValue];//接收返回值
            SYLog(@"property value is : %@", returnValue);
            if (returnValue == nil) {
                [SSWL_PublicTool showAlertToViewController:viewController alertControllerTitle:@"参数包含'nil'" alertControllerMessage:[NSString stringWithFormat:@"参数 : %@ 为nil", [NSString stringWithUTF8String:propertyName]] alertCancelTitle:@"知道了" alertReportTitle:nil cancelHandler:nil reportHandler:nil completion:nil];
                return NO;
            }
            [paramterDict setObject:returnValue forKey:[NSString stringWithUTF8String:propertyName]];
            
        }
    }
    
    return YES;
    
}


- (NSString *)description
{
    return [NSString stringWithFormat: @"productId = %@\n"
            "money = %@\n"
            "moneyType = %@\n"
            "roleId = %@\n"
            "serverId = %@\n"
            "uid = %@\n"
            "roleName = %@\n"
            "gameOrder = %@\n"
            "appId = %@\n", self.proId, self.money, self.moneyType,self.serverId, self.uid, self.roleId, self.roleName, self.YYY, self.appId];
   
}









@end
