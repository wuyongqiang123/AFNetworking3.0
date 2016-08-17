//
//  AFNetAPIClient.m
//  AFNetworking3
//
//  Created by wyq on 16/5/10.
//  Copyright © 2016年 永强. All rights reserved.
//

#import "AFNetAPIClient.h"
#import "NSJSONSerialization+LYJSON.h"
@interface AFNetAPIClient ()

@property (nonatomic,copy)NSString * url;
@property (nonatomic,assign)NetworkMethod wRequestType;
@property (assign,nonatomic)WYQHTTPClientRequestCachePolicy wRequestCache;
@property (assign,nonatomic)NSTimeInterval timeoutInterval;
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
-(void)netWorkReachability {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            {
                NSLog(@"未知信号");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                NSLog(@"手机信号");
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                NSLog(@"wiFi信号");
            }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            {
                NSLog(@"没有信号");
            }
                break;

            default:
                break;
        }
    }];
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
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
    self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json",@"text/html", nil];
    //请求格式
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    self.wRequestType = Get;
    //缓存类型
    self.wRequestCache = WYQHTTPClientReloadIgnoringLocalCacheData;
    //缓存时间默认为 60*60
    self.timeoutInterval = 60*60;
//    self.securityPolicy.allowInvalidCertificates = YES;
    //self.securityPolicy = [self customSecurityPolicy];
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
- (AFNetAPIClient* (^)(WYQHTTPClientRequestCachePolicy))Cachetype{
    return ^AFNetAPIClient* (WYQHTTPClientRequestCachePolicy type) {
        self.wRequestCache = type;

        return self;
    };
}
- (AFNetAPIClient* (^)(NSTimeInterval))time {
    return ^AFNetAPIClient* (NSTimeInterval timeoutInterval) {
        self.timeoutInterval = timeoutInterval;

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

    NSString *cacheKey = self.url?self.url:@"";
    if (self.parameters) {
        if (![NSJSONSerialization isValidJSONObject:self.parameters]) return;//参数不是json类型
        NSData *data = [NSJSONSerialization dataWithJSONObject:self.parameters options:NSJSONWritingPrettyPrinted error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        cacheKey = [cacheKey stringByAppendingString:paramStr];
    }
    //初始化缓存
    EGOCache *egocache = [EGOCache globalCache];
    //设置缓存时间 默认时间一天  一天的时间表示：24*60*60
    egocache.defaultTimeoutInterval = self.timeoutInterval;
    //获取缓存
    id object = [egocache objectForKey:cacheKey];
    switch (self.wRequestCache) {
        case WYQHTTPClientReturnCacheDataThenLoad: {//先返回缓存，同时请求
            if (object) {
                Success(nil,object);
            }
            break;
        }
        case WYQHTTPClientReloadIgnoringLocalCacheData: {//忽略本地缓存直接请求
            //不做处理，直接请求
            break;
        }
        case WYQHTTPClientReturnCacheDataElseLoad: {//有缓存就返回缓存，没有就请求
            if (object) {//有缓存
                Success(nil,object);
                return ;
            }
            break;
        }
        case WYQHTTPClientReturnCacheDataDontLoad: {//有缓存就返回缓存,从不请求（用于没有网络）
            if (object) {//有缓存
                Success(nil,object);

            }
            return ;//退出从不请求
        }
        default: {
            break;
        }
    }

    switch (self.wRequestType) {
        case Get: {
            [manager GET:self.url parameters:self.parameters progress:^(NSProgress * _Nonnull downloadProgress) {
//                progress(downloadProgress.fractionCompleted)
                Progress(downloadProgress);//downloadProgress.fractionCompleted
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [egocache setObject:responseObject forKey:cacheKey];

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
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [egocache setObject:responseObject forKey:cacheKey];
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
            }];
        }
            break;

        case Put: {
            [manager PUT:self.url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [egocache setObject:responseObject forKey:cacheKey];
                Success(task,responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                Fail(task,error);
            }];
        }
            break;

        case Delete: {
            [manager DELETE:self.url parameters:self.parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if ([responseObject isKindOfClass:[NSData class]]) {
                    responseObject = [NSJSONSerialization objectWithJSONData:responseObject];
                }
                [egocache setObject:responseObject forKey:cacheKey];
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

-(NSURLSessionDownloadTask *)downloadWithSuccess:(WYQFileSuccess)WSuccess progress:(WYQProgress)Progress failure:(WYQResponseFail)Fail {
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
    return  downloadtask;
}

- (AFNetAPIClient *)setupHTTPHeaderWithManager:(AFNetAPIClient *)manager {
    for (NSString * key in self.wHTTPHeader.allKeys) {
        [manager.requestSerializer setValue:self.wHTTPHeader[key] forHTTPHeaderField:key];
    }
    return manager;
}

- (void)cancelAllRequest {

    [self.operationQueue cancelAllOperations];
}

#pragma mark - https认证
- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"cer"]; //证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];

    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];

    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;

    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    NSSet * set = [NSSet setWithObject:certData];
    securityPolicy.pinnedCertificates = set;

    return securityPolicy;
}

@end
