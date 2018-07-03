//
//  CYCKeyChain.h
//  CYC
//
//  Created by Don on 15/6/18.
//  Copyright (c) 2015年 cycang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Security/Security.h"

@interface KeyChainWrapper : NSObject

+ (void)save:(NSString *)key data:(id)data;

+ (id)load:(NSString *)key;

+ (void)delete:(NSString *)key;

@end
































