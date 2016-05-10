//
//  AFNetAPIClient.h
//  AFNetworking3
//
//  Created by wyq on 16/5/10.
//  Copyright © 2016年 永强. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

//请求方式
typedef enum {
    Get = 0,
    Post,
    Put,
    Delete
} NetworkMethod;

/**
 *  请求成功所走方法
 *
 *  @param response 请求返还的数据
 */
typedef void (^WYQResponseSuccess)(NSURLSessionDataTask * task,id responseObject);
/**
 *  请求错误所走方法
 *
 *  @param error 请求错误返还的信息
 */
typedef void (^WYQResponseFail)(NSURLSessionDataTask * task, NSError * error);
/**
 *  进度条
 *
 *  @param progress
 */
typedef void (^WYQProgress)(NSProgress *progress);
/**
 *  上传文件成功回调
 *
 *  @param response response
 *  @param filePath filePath
 */
typedef void(^WYQFileSuccess)(NSURLResponse * response,NSURL * filePath);

@interface AFNetAPIClient : AFHTTPSessionManager

+ (AFNetAPIClient *)sharedJsonClient;//单例


/**
 *  @method      请求网址
 */
- (AFNetAPIClient* (^)(NSString * url))setRequest;

/**
 *  @method      请求类型，默认为GET
 */
- (AFNetAPIClient* (^)(NetworkMethod type))RequestType;
/**
 *  @method      请求参数
 */
- (AFNetAPIClient* (^)(id parameters))Parameters;
/**
 *  @method      请求头
 */
- (AFNetAPIClient* (^)(NSDictionary * HTTPHeaderDic))HTTPHeader;

//................................下面是上传文件.................//
/**
 *  上传的文件NSData
 */
- (AFNetAPIClient* (^)(NSData * file_data))filedata;
/**
 *  上传的文件的参数名
 */
- (AFNetAPIClient* (^)(NSString * name))name;
/**
 *  上传的文件的文件名（要有后缀名）
 */
- (AFNetAPIClient* (^)(NSString * filename))filename;
/**
 *  上传的文件的文件类型
 */
- (AFNetAPIClient* (^)(NSString * mimeType))mimeType;

//................................end.................//
/**
 *  发送请求
 *
 *  @param Success  成功的回调
 *  @param Progress 进度的回调
 *  @param Fail     请求错误的回调
 */
- (void)startRequestWithSuccess:(WYQResponseSuccess)Success progress:(WYQProgress)Progress failure:(WYQResponseFail)Fail;
/**
 *  上传文件
 *
 *  @param Success  成功的回调
 *  @param Progress 进度的回调
 *  @param Fail     请求错误的
 */
-(void)uploadfileWithSuccess:(WYQResponseSuccess)Success progress:(WYQProgress)Progress failure:(WYQResponseFail)Fail;
/**
 *  下载文件
 *
 *  @param Success  成功的回调
 *  @param Progress 进度的回调
 *  @param Fail     请求错误的
 */
-(void)downloadWithSuccess:(WYQFileSuccess)WSuccess progress:(WYQProgress)Progress failure:(WYQResponseFail)Fail;

@end
