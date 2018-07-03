//
//  CYCKeyChain.m
//  CYC
//
//  Created by Don on 15/6/18.
//  Copyright (c) 2015年 cycang. All rights reserved.
//

#import "KeyChainWrapper.h"

@interface KeyChainWrapper ()

@end

@implementation KeyChainWrapper

/**
 *  获取钥匙串的配置信息
 *
 *
 *  @return 配置信息
 */
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            key, (id)kSecAttrService,
            key, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}


/**
 *  在钥匙串中保存信息
 *
 *  @param data 需保存的数据
 */
+ (void)save:(NSString *)key data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    //Delete old item before add new item
    SecItemDelete((CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
    
}

/**
 *  获取钥匙串中保存的信息
 *
 *
 *  @return 钥匙串的数据
 */
+ (id)load:(NSString *)key {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", key, e);
        } @finally {
        }
    }
    return ret;
}

/**
 *  删除钥匙串中保存的信息
 *
 */
+ (void)delete:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    SecItemDelete((CFDictionaryRef)keychainQuery);
//    NSLog(@"keychainQuery的引用计数值：%ld",CFGetRetainCount((__bridge CFTypeRef)(keychainQuery)));
}

@end
