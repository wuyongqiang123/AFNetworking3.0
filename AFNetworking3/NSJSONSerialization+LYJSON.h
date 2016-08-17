//
//  NSJSONSerialization+LYJSON.h
//  LYHttpClient
//
//  Created by 永强 on 16/8/10.
//  Copyright © 2016年 永强. All rights reserved.
//  解析json
//  json之间的转换

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (LYJSON)
//json转字符串
+ (nullable NSString *)stringWithJSONObject:(nonnull id)JSONObject;
//字符串转json
+ (nullable id)objectWithJSONString:(nonnull NSString *)JSONString;
//nsdata 转json
+ (nullable id)objectWithJSONData:(nonnull NSData *)JSONData;
@end
