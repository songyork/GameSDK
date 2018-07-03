//
//  NSString+SYAttributes.m
//  AYSDK
//
//  Created by 松炎 on 2017/7/27.
//  Copyright © 2017年 SDK. All rights reserved.
//

#import "NSString+SYAttributes.h"

@implementation NSString (SYAttributes)


/** 字符串转属性字符串 words(要改变属性的文字) 和 attributes（属性字典）两个数组要--对应*/
- (NSAttributedString *)getAttributedStringWithChangeWordArray:(NSArray *)words andAttributeArray:(NSArray *)attributes
{
    // 属性字符串
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:self];
    
    if (words.count == 0 || attributes.count == 0) {
        
        SYLog(@"传入空的搜索字符串数组 或者 空的 属性字典 数组");
        return attriString;
        
    }else{
        
        
        for (int i = 0; i <= words.count - 1; i++)
        {
            
            NSString *searchStr = words[i];
            
            if (searchStr.length < 1 || ![self containsString:searchStr]) {
                break;
            }
            
            
            NSDictionary *subStrAttribute;
            
            if (i < attributes.count)
            {
                subStrAttribute = attributes[i];
            }else // 若属性数组元素少于文字数组元素个数，取值越界时使用最后一个
            {
                subStrAttribute = attributes.lastObject;
            }
            
            NSArray *results = [self rangesOfSearchString:searchStr];
            
            [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if (obj && [obj isKindOfClass:[NSValue class]])
                {
                    NSValue *value = obj;
                    NSRange range = value.rangeValue;
                    // 设置属性
                    [attriString setAttributes:subStrAttribute range:range];
                }
            }];
        }
        
    }
    return attriString;
}

-(NSMutableArray *)rangesOfSearchString:(NSString *)searchStr
{
    if (!searchStr) {
        SYLog(@"传入空搜索字符串");
        return nil;
    }
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    NSRange searchRange = NSMakeRange(0, [self length]);
    NSRange range;
    //依次取出判断是否未找到, 减去上一次取出的长度
    while (( range = [self rangeOfString:searchStr options:0 range:searchRange]).location!= NSNotFound ) {
        [results addObject:[NSValue valueWithRange:range]];
        
        searchRange = NSMakeRange(NSMaxRange(range), [self length] - NSMaxRange(range));
    }
    
    return results;
}

/** 字符串转属性字符串 words(要改变属性的文字) 和 attributes（属性字典）两个数组要--对应*/
- (NSAttributedString *)toAttributedStringWithChangeWords:(NSArray *)words andAttributes:(NSArray *)attributes
{
    // 属性字符串
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:self];
    
    if (words.count == 0 || attributes.count == 0) {
        
        return attriString;
        
    }else{
        
        for (int i = 0; i <= words.count - 1; i++) {
            
            NSString *str = words[i];
            
            if (str.length < 1 || ![self containsString:str]) {
                break;
            }
            
            NSArray *array=[self componentsSeparatedByString:str];
            
            NSMutableArray *arrayOfLocation=[NSMutableArray new];
            
            int d=0;
            
            for (int j=0; j < array.count-1; j++) {
                
                NSString *string=array[j];
                
                NSNumber *number=[NSNumber numberWithInt:d+=string.length];
                
                d+=str.length;
                
                [arrayOfLocation addObject:number];// 数组里面放着所有指定字符起始位置
                
            }
            NSDictionary *subStrAttribute;
            if (i < attributes.count) {
                subStrAttribute = attributes[i];
            }else
            {
                // 若属性数组元素少于文字数组元素个数，取值越界时使用最后一个
                subStrAttribute = attributes.lastObject;
            }
            
            for (int k = 0; k <= arrayOfLocation.count-1; k++) {
                
                NSNumber *num = arrayOfLocation[k];
                NSInteger location = num.intValue;
                
                NSRange range = NSMakeRange(location, str.length);
                
                // 设置属性
                [attriString setAttributes:subStrAttribute range:range];
            }
        }
        
    }
    return attriString;
}

- (NSAttributedString *)toAttributedStringWithChangeWords:(NSArray *)words Attributes:(NSArray *)attributes andInsertImage:(UIImage *)image intoIndex:(NSUInteger)index bounds:(CGRect)b{
    
    NSMutableAttributedString *attrStr01 = (NSMutableAttributedString *)[self toAttributedStringWithChangeWords:words andAttributes:attributes];
    
    NSTextAttachment *textAttachment01 = [[NSTextAttachment alloc] init];
    textAttachment01.image = image;  //设置图片源
    
    if(b.size.width && b.size.height) {
        textAttachment01.bounds = b;
    }else{
        textAttachment01.bounds = CGRectMake(0, -4, 25, 18);//设置图片位置和大小
    }
    
    NSAttributedString *attrStr02 = [NSAttributedString attributedStringWithAttachment: textAttachment01];
    
    [attrStr01 insertAttributedString: attrStr02 atIndex: index]; //NSTextAttachment占用一个字符长度，插入后原字符串长度增加1
    
    
    return attrStr01;
}
- (NSAttributedString *)toAttributedStringWithChangeWords:(NSArray *)words Attributes:(NSArray *)attributes andInsertImage:(UIImage *)image withRect:(CGRect)bounds intoIndex:(NSUInteger)index{
    
    NSMutableAttributedString *attrStr01 = (NSMutableAttributedString *)[self toAttributedStringWithChangeWords:words andAttributes:attributes];
    NSTextAttachment *textAttachment01 = [[NSTextAttachment alloc] init];
    textAttachment01.image = image;  //设置图片源
    
    textAttachment01.bounds = bounds;    //设置图片位置和大小
    
    NSAttributedString *attrStr02 = [NSAttributedString attributedStringWithAttachment: textAttachment01];
    
    [attrStr01 insertAttributedString: attrStr02 atIndex: index]; //NSTextAttachment占用一个字符长度，插入后原字符串长度增加1
    
    
    return attrStr01;
}


@end
