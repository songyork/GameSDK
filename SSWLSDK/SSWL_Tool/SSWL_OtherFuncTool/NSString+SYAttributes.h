//
//  NSString+SYAttributes.h
//  AYSDK
//
//  Created by 松炎 on 2017/7/27.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SYAttributes)



/** 获取字符串转属性字符串 words(要改变属性的文字数组) 和 attributes（属性字典数组）两个数组要--对应*/
- (NSAttributedString *)getAttributedStringWithChangeWordArray:(NSArray *)words
                                             andAttributeArray:(NSArray *)attributes;

/** 字符串转属性字符串 words(要改变属性的文字) 和 attributes（属性字典）两个数组要--对应*/
- (NSAttributedString *)toAttributedStringWithChangeWords:(NSArray *)words
                                            andAttributes:(NSArray *)attributes;

/** 字符串转属性字符串(插入图片) words(要改变属性的文字) 和 attributes（属性字典）两个数组要--对应*/
//- (NSAttributedString *)toAttributedStringWithChangeWords:(NSArray *)words Attributes:(NSArray *)attributes andInsertImage:(UIImage *)image intoIndex:(NSUInteger)index;

/** 字符串转属性字符串(插入图片，可调图片大小) words(要改变属性的文字) 和 attributes（属性字典）两个数组要--对应*/
- (NSAttributedString *)toAttributedStringWithChangeWords:(NSArray *)words
                                               Attributes:(NSArray *)attributes
                                           andInsertImage:(UIImage *)image
                                                intoIndex:(NSUInteger)index
                                                   bounds:(CGRect)b;

@end
