//
//  SS_HtmlInfoToUserModel.m
//  SSSDK
//
//  Created by SDK on 2018/3/10.
//  Copyright © 2018年 SDK. All rights reserved.
//

#import "SSWL_HtmlInfoToUserModel.h"

@implementation SSWL_HtmlInfoToUserModel

- (NSDictionary *)paramterIsNotStringFromDictionary:(NSDictionary *)dictionary{
    NSMutableDictionary *paramterDict = [NSMutableDictionary dictionary];
    
    for (id key in dictionary) {
        if (![[dictionary valueForKey:key] isKindOfClass:[NSString class]]) {
            [paramterDict setValue:[NSString stringWithFormat:@"%@", [dictionary valueForKey:key]] forKey:key];
        }else{
            [paramterDict setValue:[dictionary valueForKey:key] forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:paramterDict];
}

@end
