//
//  AFNetAPIClient.m
//  AFNetworking3
//
//  Created by wyq on 16/5/10.
//  Copyright © 2016年 永强. All rights reserved.
//

#import "AFNetAPIClient.h"

@interface AFNetAPIClient ()

@property (nonatomic,copy)NSString * url;
@property (nonatomic,assign)NetworkMethod wRequestType;
@property (nonatomic,strong)NSData * Wyqfile_data;
@property (nonatomic,copy)NSString * Wyqname;
@property (nonatomic,copy)NSString * Wyqfilename;
@property (nonatomic,copy)NSString * WyqmimeType;
@property (nonatomic,copy)id parameters;
@property (nonatomic,copy)NSDictionary * wHTTPHeader;

@end
@implementation AFNetAPIClient
+ (AFNetAPIClient *)sharedJsonClient {
    static AFNetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[AFNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.nongji360.com/"]];
    });
    
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    //返回类型默认JSON
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    //超时时间
    self.requestSerializer.timeoutInterval = 20;
    //返回格式
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", nil];
    //请求格式
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.wRequestType = Get;
//    self.securityPolicy.allowInvalidCertificates = YES;

    
    return self;
}

- (AFNetAPIClient *(^)(NSString *))setRequest {
    return ^AFNetAPIClient* (NSString * url) {
        self.url = url;
        return self;
    };
}

- (AFNetAPIClient *(^)(NetworkMethod))RequestType {
    return ^AFNetAPIClient* (NetworkMethod type) {
        self.wRequestType = type;

        return self;
    };
}

- (AFNetAPIClient* (^)(id parameters))Parameters {
    return ^AFNetAPIClient* (id parameters) {
        self.parameters = parameters;
        return self;
    };
}
- (AFNetAPIClient *(^)(NSDictionary *))HTTPHeader {
    return ^AFNetAPIClient* (NSDictionary * HTTPHeaderDic) {
        self.wHTTPHeader = HTTPHeaderDic;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSData * file_data))filedata {
    return ^AFNetAPIClient* (NSData * file_data) {
        self.Wyqfile_data = file_data;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSString * name))name {
    return ^AFNetAPIClient* (NSString * name) {
        self.Wyqname = name;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSString * filename))filename {
    return ^AFNetAPIClient* (NSString * filename) {
        self.Wyqfilename = filename;
        return self;
    };
}
- (AFNetAPIClient* (^)(NSString * mimeType))mimeType {
    return ^AFNetAPIClient* (NSString * mimeType) {
        self.WyqmimeType = mimeType;
        return self;
    };
}

- (void)startRequestWithSuccess:(WYQResponseSuccess)Success progress:(WYQProgress)Progress failure:(WYQResponseFail)Fail {

     AFNetAPIClient * manager = [[self class]sharedJsonClient];
    //设置请求头
    [self setupHTTPHeaderWithManager:manager];
    
    switch (self.wRequestType) {
        case Get: {
            [manager GET:self.url parameters:self.parameters progress:^(NSProgress * _Nonnull downloadProgress) {
//                progress(downloadProgress.fractionCompleted)
                Progress(downloadProgress);//downloadProgress.fractionCompleted
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
            }];
        }
            break;

        case Post: {
            [manager POST:self.url parameters:self.parameters progress:^(NSProgress * _Nonnull downloadProgress) {
                Progress(downloadProgress);
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
            }];
        }
            break;

        case Put: {
            [manager PUT:self.url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
            }];
        }
            break;

        case Delete: {
            [manager DELETE:self.url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               Fail(task,error);
            }];
        }
            break;

        default:
            break;
    }


}

-(void)uploadfileWithSuccess:(WYQResponseSuccess)Success progress:(WYQProgress)Progress failure:(WYQResponseFail)Fail {
    AFNetAPIClient * manager = [[self class]sharedJsonClient];
    [manager POST:self.url parameters:self.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:self.Wyqfile_data name:self.Wyqname fileName:self.Wyqfilename mimeType:self.WyqmimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        Progress(uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Success(task,responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Fail(task,error);
    }];
}

-(void)downloadWithSuccess:(WYQFileSuccess)WSuccess progress:(WYQProgress)Progress failure:(WYQResponseFail)Fail {
    AFNetAPIClient * manager = [[self class]sharedJsonClient];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSURLSessionDownloadTask *downloadtask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        Progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //保存文件url (可自己改)
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSURL *fileUrl = [NSURL fileURLWithPath:cachesPath];

        return [fileUrl URLByAppendingPathComponent:[response suggestedFilename]];

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            Fail(nil,error);
        }
        else{
            WSuccess(response,filePath);
        }
    }];
    [downloadtask resume];
}

- (AFNetAPIClient *)setupHTTPHeaderWithManager:(AFNetAPIClient *)manager {
    for (NSString * key in self.wHTTPHeader.allKeys) {
        [manager.requestSerializer setValue:self.wHTTPHeader[key] forHTTPHeaderField:key];
    }
    return manager;
}


@end
